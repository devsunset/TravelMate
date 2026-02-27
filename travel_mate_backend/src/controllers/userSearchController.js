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
const Sequelize = require('sequelize');
const { Op } = Sequelize;
const User = require('../models/user');
const UserProfile = require('../models/userProfile');
const Tag = require('../models/tag');
const Itinerary = require('../models/itinerary');

/** 동행 검색: 프로필·태그 조건으로 사용자 목록 조회 후 페이징 반환 */
exports.searchCompanions = async (req, res, next) => {
  try {
    const { destination, preferredLocation, gender, ageRange, travelStyles, interests, startDate, endDate, keyword, limit = 10, offset = 0 } = req.query;

    // travelStyles, interests: 배열 또는 쉼표 구분 문자열 지원
    const travelStylesArr = !travelStyles ? [] : Array.isArray(travelStyles) ? travelStyles : String(travelStyles).split(',').map(s => s.trim()).filter(Boolean);
    const interestsArr = !interests ? [] : Array.isArray(interests) ? interests : String(interests).split(',').map(s => s.trim()).filter(Boolean);

    // 본인 제외: 등록된 다른 사용자만 표시
    const currentUid = req.user?.uid;
    const whereConditions = currentUid ? { firebase_uid: { [Op.ne]: currentUid } } : {};
    // [동행 검색] 질의 조건 조립 (UserProfile 조건)
    const profileWheres = [];

    // 1. 키워드 검색 (닉네임 또는 소개)
    if (keyword) {
      profileWheres.push({
        [Op.or]: [
          { nickname: { [Op.like]: `%${keyword}%` } },
          { bio: { [Op.like]: `%${keyword}%` } },
        ]
      });
    }

    // 2. 선호 지역 검색 (JSON 컬럼 -> CHAR 캐스팅 후 LIKE)
    if (preferredLocation) {
      profileWheres.push(
        Sequelize.where(
          Sequelize.cast(Sequelize.col('UserProfile.preferredDestinations'), 'CHAR'),
          { [Op.like]: `%${preferredLocation}%` }
        )
      );
    }

    // 3. 성별 필터
    if (gender && gender !== 'Any' && gender !== '무관') {
      profileWheres.push({ gender });
    }

    // 4. 연령대 필터
    if (ageRange && ageRange !== 'Any' && ageRange !== '무관') {
      profileWheres.push({ ageRange });
    }

    // 5. 여행 스타일 (JSON 배열 내 OR 매칭 -> CHAR 캐스팅 후 LIKE 조합)
    if (travelStylesArr.length > 0) {
      const styleConditions = travelStylesArr.map(style =>
        Sequelize.where(
          Sequelize.cast(Sequelize.col('UserProfile.travelStyles'), 'CHAR'),
          { [Op.like]: `%${style}%` }
        )
      );
      profileWheres.push({ [Op.or]: styleConditions });
    }

    // 6. 관심사 (JSON 배열 내 OR 매칭 -> CHAR 캐스팅 후 LIKE 조합)
    if (interestsArr.length > 0) {
      const interestConditions = interestsArr.map(interest =>
        Sequelize.where(
          Sequelize.cast(Sequelize.col('UserProfile.interests'), 'CHAR'),
          { [Op.like]: `%${interest}%` }
        )
      );
      profileWheres.push({ [Op.or]: interestConditions });
    }

    const includeConditions = [
      {
        model: UserProfile,
        as: 'UserProfile',
        required: true,
        where: profileWheres.length > 0 ? { [Op.and]: profileWheres } : {},
      }
    ];

    // Filter by itinerary (destination or dates)
    const hasItineraryFilter = destination || startDate || endDate;
    if (hasItineraryFilter) {
      const itinerayWhere = [];

      if (destination) {
        itinerayWhere.push({ title: { [Op.like]: `%${destination}%` } });
      }

      if (startDate || endDate) {
        if (startDate && endDate) {
          itinerayWhere.push({
            [Op.and]: [
              { startDate: { [Op.lte]: endDate } },
              { endDate: { [Op.gte]: startDate } }
            ]
          });
        } else if (startDate) {
          itinerayWhere.push({ endDate: { [Op.gte]: startDate } });
        } else if (endDate) {
          itinerayWhere.push({ startDate: { [Op.lte]: endDate } });
        }
      }

      includeConditions.push({
        model: Itinerary,
        as: 'Itineraries',
        required: true,
        where: itinerayWhere.length > 0 ? { [Op.and]: itinerayWhere } : {},
      });
    }


    const users = await User.findAndCountAll({
      where: whereConditions,
      include: includeConditions,
      limit: parseInt(limit),
      offset: parseInt(offset),
      attributes: ['firebase_uid', 'id'],
    });


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