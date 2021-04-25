const Item = require('../models/item');
const User = require('../models/user');
exports.getAllItems = (req, res) => {
  Item.find({}).exec((err, result) => {
    if (err) {
      return res.status(400).json(err);
    }
    res.status(200).json(result);
  });
};

exports.getSingleItem = (req, res) => {
  console.log(req.params);
  Item.findOne({ id: req.params.id }).exec((err, result) => {
    if (err) {
      return res.status(400).json(err);
    }
    res.status(200).json(result);
  });
};

exports.saveItem = (req, res) => {
  User.findOne({ _id: req.user._id }).exec((err, user) => {
    if (err) {
      return res.status(400).json(err);
    }
    Item.findOne({ _id: req.body.productId }).exec((err, item) => {
      if (err) {
        return res.status(400).json(err);
      }
      user.savedItems = user.savedItems.concat({ item });
      user.save();
    });
    res.json(user);
  });
};
