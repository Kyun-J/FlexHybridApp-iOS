const webpack = require("webpack");
const path = require("path");

const config = {
  mode: process.env.NODE_ENV,
  context: __dirname + "/origin",
  entry: {
    "iOS": "./iOS.js",
  },
  output: {
    path:  path.resolve(__dirname, "../js"),
    filename: "FlexHybridiOS.js",
  },
  resolve: {
    extensions: [".js"],
  },
  module: {
    rules: [
      {
        test: /\.(js)$/,
        loader: "babel-loader",
        exclude: /node_modules/,
      },
    ],
  },
  plugins: [
    new webpack.DefinePlugin({
      global: "window",
    })
  ],
};

if (config.mode === "production") {
  config.plugins = (config.plugins || []).concat([
    new webpack.DefinePlugin({
      "process.env": {
        NODE_ENV: '"production"',
      },
    }),
  ]);
}

module.exports = config;
