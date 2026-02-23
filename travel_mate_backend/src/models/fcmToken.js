/**
 * FCM 토큰 모델 (fcm_tokens 테이블)
 * 푸시 알림 전송을 위한 사용자별 FCM 디바이스 토큰을 저장합니다.
 * (userId, token) 조합은 유일합니다.
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./user');

const FcmToken = sequelize.define('FcmToken', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  userId: {
    type: DataTypes.STRING(32),
    allowNull: false,
    references: { model: User, key: 'id' },
    onDelete: 'CASCADE',
  },
  token: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  deviceType: {
    type: DataTypes.STRING, // 예: 'android', 'ios', 'web'
    allowNull: true,
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  updated_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'fcm_tokens',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [{ unique: true, fields: ['userId', 'token'] }],
});

FcmToken.belongsTo(User, { foreignKey: 'userId' });

module.exports = FcmToken;
