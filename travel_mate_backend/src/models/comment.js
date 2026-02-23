/**
 * 댓글 모델 (comments 테이블)
 * 게시글 또는 일정에 달리는 댓글·대댓글을 저장합니다.
 * postId / itineraryId 중 하나는 반드시 존재해야 하며, 앱 로직에서 보장합니다.
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./user');
const Post = require('./post');
const Itinerary = require('./itinerary');

const Comment = sequelize.define('Comment', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  authorId: {
    type: DataTypes.STRING(255),
    allowNull: false,
    references: { model: User, key: 'email' },
    onDelete: 'CASCADE',
  },
  postId: {
    type: DataTypes.INTEGER,
    allowNull: true, // 일정 댓글일 경우 null
    references: { model: Post, key: 'id' },
    onDelete: 'CASCADE',
  },
  itineraryId: {
    type: DataTypes.INTEGER,
    allowNull: true, // 게시글 댓글일 경우 null
    references: { model: Itinerary, key: 'id' },
    onDelete: 'CASCADE',
  },
  parentCommentId: {
    type: DataTypes.INTEGER,
    allowNull: true, // 대댓글인 경우 부모 댓글 id
    references: { model: 'comments', key: 'id' },
    onDelete: 'CASCADE',
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
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
  tableName: 'comments',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

Comment.belongsTo(User, { as: 'Author', foreignKey: 'authorId' });
Comment.belongsTo(Post, { foreignKey: 'postId' });
Comment.belongsTo(Itinerary, { foreignKey: 'itineraryId' });
Comment.hasMany(Comment, { as: 'Replies', foreignKey: 'parentCommentId' });
Comment.belongsTo(Comment, { as: 'ParentComment', foreignKey: 'parentCommentId' });
Post.hasMany(Comment, { foreignKey: 'postId', as: 'Comments' });
Itinerary.hasMany(Comment, { foreignKey: 'itineraryId', as: 'Comments' });

module.exports = Comment;
