/**
 * 사용자 프로필 컨트롤러
 * 프로필 조회·수정·프로필 이미지 URL 갱신을 처리합니다.
 */

const UserProfile = require('../models/userProfile');
const User = require('../models/user');

/**
 * 프로필 조회
 * params.userId는 Firebase UID. 프로필이 없으면 기본값으로 생성 후 반환합니다.
 */
exports.getUserProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const user = await User.findOne({ where: { firebase_uid: userId } });
    if (!user) {
      return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
    }

    let userProfile = await UserProfile.findOne({ where: { userId: user.id } });

    if (!userProfile) {
      userProfile = await UserProfile.create({
        userId: user.id,
        nickname: `user_${user.firebase_uid.substring(0, 8)}`,
        bio: '',
        profileImageUrl: '',
        gender: '',
        ageRange: '',
        travelStyles: [],
        interests: [],
        preferredDestinations: [],
      });
      return res.status(201).json({ message: '프로필이 생성되었습니다.', userProfile });
    }

    res.status(200).json({ userProfile });
  } catch (error) {
    console.error('getUserProfile 오류:', error);
    next(error);
  }
};

/**
 * 프로필 수정
 * body의 nickname, bio, profileImageUrl, gender, ageRange, travelStyles, interests, preferredDestinations 반영.
 * 본인만 수정 가능합니다.
 */
exports.updateUserProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { nickname, bio, profileImageUrl, gender, ageRange, travelStyles, interests, preferredDestinations } = req.body;

    if (req.user.uid !== userId) {
      return res.status(403).json({ message: '본인 프로필만 수정할 수 있습니다.' });
    }

    const user = await User.findOne({ where: { firebase_uid: userId } });
    if (!user) {
      return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
    }

    let userProfile = await UserProfile.findOne({ where: { userId: user.id } });

    if (!userProfile) {
      userProfile = await UserProfile.create({
        userId: user.id,
        nickname,
        bio,
        profileImageUrl,
        gender,
        ageRange,
        travelStyles,
        interests,
        preferredDestinations,
      });
      return res.status(201).json({ message: '프로필이 생성·수정되었습니다.', userProfile });
    }

    userProfile.nickname = nickname;
    userProfile.bio = bio;
    userProfile.profileImageUrl = profileImageUrl;
    userProfile.gender = gender;
    userProfile.ageRange = ageRange;
    userProfile.travelStyles = travelStyles;
    userProfile.interests = interests;
    userProfile.preferredDestinations = preferredDestinations;
    await userProfile.save();

    res.status(200).json({ message: '프로필이 수정되었습니다.', userProfile });
  } catch (error) {
    console.error('updateUserProfile 오류:', error);
    next(error);
  }
};

/**
 * 프로필 이미지 URL 갱신
 * body.profileImageUrl만 저장합니다. 실제 업로드는 클라이언트에서 Firebase Storage로 수행합니다.
 */
exports.updateProfileImage = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { profileImageUrl } = req.body;

    if (req.user.uid !== userId) {
      return res.status(403).json({ message: '본인 프로필 이미지만 수정할 수 있습니다.' });
    }

    const user = await User.findOne({ where: { firebase_uid: userId } });
    if (!user) {
      return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
    }

    let userProfile = await UserProfile.findOne({ where: { userId: user.id } });

    if (!userProfile) {
      userProfile = await UserProfile.create({
        userId: user.id,
        nickname: `user_${user.firebase_uid.substring(0, 8)}`,
        profileImageUrl: profileImageUrl,
      });
    } else {
      userProfile.profileImageUrl = profileImageUrl;
      await userProfile.save();
    }

    res.status(200).json({ message: '프로필 이미지가 수정되었습니다.', profileImageUrl });
  } catch (error) {
    console.error('updateProfileImage 오류:', error);
    next(error);
  }
};
