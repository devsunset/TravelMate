/**
 * 사용자 프로필 컨트롤러
 * 프로필 조회·수정·프로필 이미지 URL 갱신을 처리합니다.
 */

const UserProfile = require('../models/userProfile');
const User = require('../models/user');
const { generateUniqueRandomNickname, isNicknameTakenByOther } = require('../utils/randomNickname');

/**
 * 프로필 조회
 * params.userId는 Firebase UID. 사용자가 DB에 없으면 토큰 정보로 자동 생성 후 프로필 생성/반환합니다.
 */
exports.getUserProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const firebaseUid = req.user?.uid || userId;
    const firebaseEmail = req.user?.email || '';

    let user = await User.findOne({ where: { firebase_uid: firebaseUid } });
    if (!user) {
      user = await User.create({ firebase_uid: firebaseUid, email: firebaseEmail || `user_${firebaseUid}@temp` });
    }

    let userProfile = await UserProfile.findOne({ where: { userId: user.id } });

    if (!userProfile) {
      const nickname = await generateUniqueRandomNickname();
      userProfile = await UserProfile.create({
        userId: user.id,
        nickname,
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
      const newNick = (nickname && nickname.trim()) ? nickname.trim() : await generateUniqueRandomNickname();
      if (nickname && nickname.trim()) {
        const taken = await isNicknameTakenByOther(newNick, user.id);
        if (taken) {
          return res.status(409).json({ message: '이미 사용 중인 닉네임입니다.' });
        }
      }
      userProfile = await UserProfile.create({
        userId: user.id,
        nickname: newNick,
        bio: bio ?? '',
        profileImageUrl: profileImageUrl ?? '',
        gender: gender ?? '',
        ageRange: ageRange ?? '',
        travelStyles: travelStyles ?? [],
        interests: interests ?? [],
        preferredDestinations: preferredDestinations ?? [],
      });
      return res.status(201).json({ message: '프로필이 생성·수정되었습니다.', userProfile });
    }

    // 닉네임 변경 시 기존 등록된 닉네임인지 체크 (본인 닉네임은 그대로 허용)
    if (nickname != null && String(nickname).trim() !== '' && String(nickname).trim() !== userProfile.nickname) {
      const newNick = String(nickname).trim();
      const taken = await isNicknameTakenByOther(newNick, user.id);
      if (taken) {
        return res.status(409).json({ message: '이미 사용 중인 닉네임입니다.' });
      }
    }

    userProfile.nickname = nickname != null && String(nickname).trim() !== '' ? String(nickname).trim() : userProfile.nickname;
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
 * body.profileImageUrl만 저장합니다. 실제 업로드는 클라이언트에서 백엔드 POST /api/upload/profile 로 수행합니다.
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
      const nickname = await generateUniqueRandomNickname();
      userProfile = await UserProfile.create({
        userId: user.id,
        nickname,
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
