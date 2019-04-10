#!/bin/bash
mkdir -p ./.cache/xfeatures2d/boostdesc
mkdir -p ./.cache/xfeatures2d/vgg

pushd ./.cache/xfeatures2d/boostdesc
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_lbgm.i > 0ae0675534aa318d9668f2a179c2a052-boostdesc_lbgm.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_binboost_256.i > e6dcfa9f647779eb1ce446a8d759b6ea-boostdesc_binboost_256.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_binboost_128.i > 98ea99d399965c03d555cef3ea502a0b-boostdesc_binboost_128.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_binboost_064.i > 202e1b3e9fec871b04da31f7f016679f-boostdesc_binboost_064.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_bgm_hd.i > 324426a24fa56ad9c5b8e3e0b3e5303e-boostdesc_bgm_hd.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_bgm_bi.i > 232c966b13651bd0e46a1497b0852191-boostdesc_bgm_bi.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_bgm.i > 0ea90e7a8f3f7876d450e4149c97c74f-boostdesc_bgm.i
popd

pushd ./.cache/xfeatures2d/vgg
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d/vgg_generated_120.i > 151805e03568c9f490a5e3a872777b75-vgg_generated_120.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d/vgg_generated_64.i > 7126a5d9a8884ebca5aea5d63d677225-vgg_generated_64.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d/vgg_generated_48.i > e8d0dcd54d1bcfdc29203d011a797179-vgg_generated_48.i
curl https://raw.githubusercontent.com/opencv/opencv_3rdparty/fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d/vgg_generated_80.i > 7cd47228edec52b6d82f46511af325c5-vgg_generated_80.i
popd
