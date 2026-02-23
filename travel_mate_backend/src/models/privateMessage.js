/**
 * 1:1 쪽지 모델 (private_messages 테이블)
 * 사용자 간 발신·수신 쪽지 내용과 읽음 여부를 저장합니다.
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./user');

const PrivateMessage = sequelize.define('PrivateMessage', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  senderId: {
    type: DataTypes.STRING(255),
    allowNull: false,
    references: { model: User, key: 'email' },
    onDelete: 'CASCADE',
  },
  receiverId: {
    type: DataTypes.STRING(255),
    allowNull: false,
    references: { model: User, key: 'email' },
    onDelete: 'CASCADE',
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  isRead: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  sent_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'private_messages',
  timestamps: false,
});

PrivateMessage.belongsTo(User, { as: 'Sender', foreignKey: 'senderId' });
PrivateMessage.belongsTo(User, { as: 'Receiver', foreignKey: 'receiverId' });

module.exports = PrivateMessage;
