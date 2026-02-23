/**
 * 동행 검색 컨트롤러
 * 쿼리: destination, gender, ageRange, travelStyles, interests, keyword, limit, offset
 */
const { Op } = require('sequelize');
const User = require('../models/user');
const UserProfile = require('../models/userProfile');
const Tag = require('../models/tag');

/** 동행 검색: 프로필·태그 조건으로 사용자 목록 조회 후 페이징 반환 */
exports.searchCompanions = async (req, res, next) => {
  try {
    const { destination, gender, ageRange, travelStyles, interests, startDate, endDate, keyword, limit = 10, offset = 0 } = req.query;

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

    // Filter by destination
    if (destination) {
      includeConditions[0].where.preferredDestinations = {
        [Op.like]: `%${destination}%`, // Assuming destinations are stored as JSON string or comma-separated
      };
    }

    // Filter by gender
    if (gender && gender !== 'Any') {
      includeConditions[0].where.gender = gender;
    }

    // Filter by age range
    if (ageRange && ageRange !== 'Any') {
      includeConditions[0].where.ageRange = ageRange;
    }

    // Filter by travel styles (many-to-many relationship via Tags)
    if (travelStylesArr.length > 0) {
      includeConditions[0].include.push({
        model: Tag,
        as: 'Tags',
        through: { attributes: [] },
        where: {
          name: { [Op.in]: travelStylesArr },
          type: 'travel_style',
        },
        required: true,
      });
    }

    // Filter by interests (many-to-many relationship via Tags)
    if (interestsArr.length > 0) {
      includeConditions[0].include.push({
        model: Tag,
        as: 'Interests',
        through: { attributes: [] },
        where: {
          name: { [Op.in]: interestsArr },
          type: 'interest',
        },
        required: true,
      });
    }

    // TODO: Implement date range filtering if applicable (requires itinerary/travel plan tables)

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