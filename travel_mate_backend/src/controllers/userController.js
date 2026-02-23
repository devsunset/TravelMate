/**
 * 사용자 계정 컨트롤러 (계정 삭제 등)
 */
const admin = require('firebase-admin');
const User = require('../models/user');

/** 계정 삭제: params.userId는 이메일(URL 인코딩됨). 본인만 삭제 가능. Firebase Auth + MariaDB 삭제 */
exports.deleteUser = async (req, res, next) => {
  try {
    const userEmail = req.params.userId ? decodeURIComponent(req.params.userId) : req.user?.email;
    if (!userEmail || req.user?.email !== userEmail) {
      return res.status(403).json({ message: '본인 계정만 삭제할 수 있습니다.' });
    }
    const user = await User.findOne({ where: { email: userEmail } });
    if (!user) {
      return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
    }
    await admin.auth().deleteUser(user.firebase_uid);
    const deletedRows = await User.destroy({ where: { id: user.id } });
    if (deletedRows === 0) {
      return res.status(404).json({ message: '데이터베이스에서 사용자를 찾을 수 없습니다.' });
    }
    // UserProfile CASCADE로 함께 삭제됨
    res.status(204).send();
  } catch (error) {
    console.error('deleteUser 오류:', error);
    if (error.code === 'auth/user-not-found') {
      return res.status(404).json({ message: 'Firebase Auth에서 사용자를 찾을 수 없습니다.' });
    }
    next(error);
  }
};