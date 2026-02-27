/**
 * 동행 검색 컨트롤러
 *
 * [검색 조건 설명]
 * - destination: 선호 목적지( preferredDestinations JSON 필드에 포함된 경우 매칭, LIKE %값% )
 * - keyword: 닉네임 또는 자기소개(bio)에 포함( LIKE %값% )
 * - gender: 성별 일치 (남성/여성). '무관'·'Any'면 조건 미적용
 * - ageRange: 연령대 일치 (10대/20대/30대/40대/50대 이상). '무관'·'Any'면 조건 미적용
 * - travelStyles: 여행 스타일(쉼표 구분). Tag 테이블 type='travel_style' 로 필터 (연관 있으면 AND)
 * - interests: 관심사(쉼표 구분). Tag 테이블 type='interest' 로 필터 (연관 있으면 AND)
 * - limit, offset: 페이징 (기본 limit=10, offset=0)
 * - 본인(firebase_uid)은 항상 제외, 프로필이 있는 사용자만 조회(INNER JOIN)
 */
const { Op } = require('sequelize');
const User = require('../models/user');
const UserProfile = require('../models/userProfile');
const Tag = require('../models/tag');
const Itinerary = require('../models/itinerary');

/** 동행 검색: 프로필·태그 조건으로 사용자 목록 조회 후 페이징 반환 */
exports.searchCompanions = async (req, res, next) => {
  try {
    const { destination, preferredLocation, gender, ageRange, travelStyles, interests, startDate, endDate, keyword, limit = 10, offset = 0 } = req.query;

    // [동행 검색] 수신 쿼리 파라미터 로그
    console.log('[동행 검색] 수신 쿼리:', JSON.stringify({
      destination: destination ?? null,
      preferredLocation: preferredLocation ?? null,
      keyword: keyword ?? null,
      gender: gender ?? null,
      ageRange: ageRange ?? null,
      travelStyles: travelStyles ?? null,
      interests: interests ?? null,
      startDate: startDate ?? null,
      endDate: endDate ?? null,
      limit,
      offset,
    }));

    // travelStyles, interests: 배열 또는 쉼표 구분 문자열 지원
    const travelStylesArr = !travelStyles ? [] : Array.isArray(travelStyles) ? travelStyles : String(travelStyles).split(',').map(s => s.trim()).filter(Boolean);
    const interestsArr = !interests ? [] : Array.isArray(interests) ? interests : String(interests).split(',').map(s => s.trim()).filter(Boolean);

    // 본인 제외: 등록된 다른 사용자만 표시
    const currentUid = req.user?.uid;
    const whereConditions = currentUid ? { firebase_uid: { [Op.ne]: currentUid } } : {};
    const includeConditions = [
      {
        model: UserProfile,
        as: 'UserProfile',
        required: true, // INNER JOIN to ensure user has a profile
        where: {},
        include: []
      }
    ];

    // Filter by keyword in nickname or bio
    if (keyword) {
      includeConditions[0].where[Op.or] = [
        { nickname: { [Op.like]: `%${keyword}%` } },
        { bio: { [Op.like]: `%${keyword}%` } },
      ];
    }

    // Filter by preferred locations (JSON column in UserProfile)
    if (preferredLocation) {
      includeConditions[0].where.preferredDestinations = {
        [Op.like]: `%${preferredLocation}%`
      };
    }

    // Filter by itinerary (destination or dates)
    const hasItineraryFilter = destination || startDate || endDate;
    if (hasItineraryFilter) {
      const itinerayWhere = {};
      if (destination) {
        itinerayWhere.title = { [Op.like]: `%${destination}%` };
      }
      if (startDate || endDate) {
        // Find itineraries that overlap with the searched range [startDate, endDate]
        // Overlap condition: (itinerary.startDate <= searched.endDate) AND (itinerary.endDate >= searched.startDate)
        if (startDate && endDate) {
          itinerayWhere[Op.and] = [
            { startDate: { [Op.lte]: endDate } },
            { endDate: { [Op.gte]: startDate } }
          ];
        } else if (startDate) {
          itinerayWhere.endDate = { [Op.gte]: startDate };
        } else if (endDate) {
          itinerayWhere.startDate = { [Op.lte]: endDate };
        }
      }

      includeConditions.push({
        model: Itinerary,
        as: 'Itineraries', // Check model association alias
        where: itinerayWhere,
        required: true, // Find only users who have a matching itinerary
      });
    }

    // Filter by gender
    if (gender && gender !== 'Any') {
      includeConditions[0].where.gender = gender;
    }

    // Filter by age range
    if (ageRange && ageRange !== 'Any') {
      includeConditions[0].where.ageRange = ageRange;
    }

    // Filter by travel styles (JSON column in UserProfile)
    if (travelStylesArr.length > 0) {
      includeConditions[0].where[Op.and] = includeConditions[0].where[Op.and] || [];
      const styleConditions = travelStylesArr.map(style => ({
        travelStyles: { [Op.like]: `%${style}%` }
      }));
      includeConditions[0].where[Op.and].push({ [Op.or]: styleConditions });
    }

    // Filter by interests (JSON column in UserProfile)
    if (interestsArr.length > 0) {
      includeConditions[0].where[Op.and] = includeConditions[0].where[Op.and] || [];
      const interestConditions = interestsArr.map(interest => ({
        interests: { [Op.like]: `%${interest}%` }
      }));
      includeConditions[0].where[Op.and].push({ [Op.or]: interestConditions });
    }

    // TODO: Implement date range filtering if applicable (requires itinerary/travel plan tables)

    // [동행 검색] 실제 질의 조건 요약 로그 (User.where + UserProfile.where + Tag 필터)
    console.log('[동행 검색] 질의 조건:', JSON.stringify({
      userWhere: whereConditions,
      profileWhere: includeConditions[0].where,
      preferredLocationFilter: preferredLocation ?? null,
      travelStylesFilter: travelStylesArr.length ? travelStylesArr : null,
      interestsFilter: interestsArr.length ? interestsArr : null,
      limit: parseInt(limit),
      offset: parseInt(offset),
    }, null, 2));

    const users = await User.findAndCountAll({
      where: whereConditions,
      include: includeConditions,
      limit: parseInt(limit),
      offset: parseInt(offset),
      attributes: ['firebase_uid', 'id'],
    });

    // [동행 검색] 질의 결과 로그
    console.log('[동행 검색] 질의 결과:', JSON.stringify({
      total: users.count,
      returned: users.rows.length,
      limit: parseInt(limit),
      offset: parseInt(offset),
      sampleNicknames: users.rows.slice(0, 3).map(r => r.UserProfile?.nickname).filter(Boolean),
    }));

    // Remap the results to a more user-friendly format, flattening UserProfile
    const formattedUsers = users.rows.map(user => {
      const userJson = user.toJSON();
      const profileJson = userJson.UserProfile;

      return {
        userId: userJson.id,
        nickname: profileJson.nickname,
        bio: profileJson.bio,
        profileImageUrl: profileJson.profileImageUrl,
        gender: profileJson.gender,
        ageRange: profileJson.ageRange,
        travelStyles: profileJson.travelStyles,
        interests: profileJson.interests,
        preferredDestinations: profileJson.preferredDestinations,
        // Potentially add matched tags or other relevant info
      };
    });

    res.status(200).json({
      total: users.count,
      limit: parseInt(limit),
      offset: parseInt(offset),
      users: formattedUsers,
    });
  } catch (error) {
    console.error('searchCompanions 오류:', error);
    next(error);
  }
};