/**
 * 게시글 카테고리 모델 (post_categories 테이블)
 * 커뮤니티 게시글 분류(일반, 팁, 스토리 등)를 저장합니다.
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PostCategory = sequelize.define('PostCategory', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  description: {
    type: DataTypes.TEXT,
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
  tableName: 'post_categories',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

module.exports = PostCategory;
