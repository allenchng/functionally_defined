---
title: Just how good is TensorFlow at categorizing images anyways?
author: Allen Chang
date: '2018-10-22'
slug: just-how-good-is-tensorflow-at-categorizing-images-anyways
categories: []
tags:
  - clothing
  - TensorFlow
  - classification
---

## Introduction

Okay, that title is a bit of a rhetorical question. Everyone knows that TensorFlow is great at categorizing images. For the purposes of my self-interest and curiosity though, I wanted to see the magic with my own eyes.

I should say straight from the start that this post won't contain any new code, and the overall goal is more for me to play around in the sandbox and learn more about how image classification models work (which I think is equally as fun!). What I'll be doing instead is utilizing code released by the TensorFlow team.  The TensorFlow team has an [excellent tutorial](https://www.tensorflow.org/hub/tutorials/image_retraining) on how to take a pre-trained image classifier model and adapt it to identify images from new categories. In the tutorial, the TensorFlow team provides scripts to do retraining and model evaluation, which is what I'll be implementing.

As for what image categories to do my retraining on, of course my first thought was clothing categories. This time though, there's a prior link to machine learning! There's a well known data set that's used for testing machine learning models called the [fashion-mnist](https://github.com/zalandoresearch/fashion-mnist). The fashion-mnist is composed of grayscale images associated with 10 different classes of clothing  (if you're interested in learning more about the fashion-mnist, the TensorFlow team has a great [introductory video](https://www.youtube.com/watch?v=FiNglI1wRNk).  The original intent of fashion-mnist was to provide a more difficult classification problem than the origin mnist. In my tests, I am going to examine how well a pre-trained model in TensorFlow identifies large, color images of clothes across 5 different categories; pants, shoes, outerwear, tops, and suits. 

## Getting started

Setting up the image retraining is straightforward. The [TensorFlow website](https://codelabs.developers.google.com/codelabs/tensorflow-for-poets/index.html#0) has instructions on how to download all the scripts and examples necessary for the tutorial.

For retraining, the most important process is to set up your training data in folders that are named with the categories you want to predict.

![folder structure](https://lh3.googleusercontent.com/cctmIPgb6vn6TqkFO_9GPfF6aCmgnvHL25wet9ThIsAfGUhaHphNv_uoRs1TX8PlrFoe7NAkg7N8)

## Data and Categories

I wanted to select pictures with uniform size and high quality photography for retraining. Luckily, one of my friends works for a [men's clothing store](nomanwalksalone.com) that A) has high standards for photography B) has a wide variety of clothes from different categories and C) has consistent sizing for photos. With his permission, I downloaded images from a variety of categories using my image scraping script from a [previous post](https://functionallydefined.netlify.com/posts/web-scraping-the-2017-most-popular-fit-pictures-on-styleforum-s-what-are-you-wearing-today-thread/). 

For retraining classifiers, the TensorFlow  team recommends that you have at least 100 samples to train on. I organized the photos into 5 categories; Pants, Shoes, Outerwear, Tops, and Suits. A representative picture from each category is labeled below.

Pants
![Pants](https://lh3.googleusercontent.com/KCiO_bF0IF1Pd0yXokVSlMA0FEi4HxR9NXPlajxOZNVoDrplu2pSzmfU5MBFUrNfMLXpObt7T57T)
Shoes
![Shoes](https://lh3.googleusercontent.com/q0T3FvYhK_cYxCY5bUTGO-RIyt9V3pagWpbW3cVh0Ou-1asB1jskZ07qX2rvPdM1uNTYckmjWDum "Shoes")
Outerwear
![Outerwear](https://lh3.googleusercontent.com/m7JAm9isB-Gs2jL8N-Gftkqm-6tlSrmDWhjnvOTZzAkN26gwZXcKcvMuzVtFmGn1uGfCdxNjr66y "Outerwear")
Top
![Shirt](https://lh3.googleusercontent.com/Fzl3wS4C5RzjretCtc5r4U2y4EaTt5-t212rFXvXjDXcdzw8xEAQe3076qauw_ILdo6VBMJxszIQ)
Suit
![Suit](https://lh3.googleusercontent.com/qZfHd_R5zrSUjiexlGzMkltjHUwp3rd1ICZJyBCDLYUDENwKZ7zcDIBzsqmuBV2YbLZZfSQCOD4L)

## Retraining models

Model retraining is conducted by taking a pre-trained neural network model and then training a new layer on top. The model retraining process has 2 steps; recalculating bottleneck layers and training. The retraining script sets the top layers of the neural network to be trainable and recalculates the bottleneck layer and then stores the weights for use in the training phase. Bottleneck layers help reduce the number of parameters by using a mixture of convolutions along with fewer output channels. Bottlenecks are important because they need to compress information, but also must generalize well enough to allow the classifier to make good choices. 

During the training phase, a new classification layer is added to the network. The script iterates through batches of training images and displays the training accuracy, accuracy on held out validation data, and the cross entropy loss. The training procedure attempts to maximize accuracy and minimize the loss on each batch of data.

For this post, I stuck with the default classifier, an [Inception V3](https://arxiv.org/abs/1512.00567) neural network architecture trained on ImageNet. I manually specified the resolution of my images (505x505) and set the relative size of the model to be half of the largest ImageNet (0.5). Higher resolution photos and larger relative model sizes can lead to better classification accuracy, but take longer to retrain.

```
IMAGE_SIZE=505
ARCHITECTURE="imagenet_0.50_${IMAGE_SIZE}"

python retrain.py \
   --learning_rate=0.05 \
   --bottleneck_dir=tmp/bottlenecks \
   --model_dir=tmp/models/ \
   --summaries_dir=tmp/training_summaries/LR_.05 \
   --output_graph=tmp/retrained_graph.pb \
   --output_labels=tmp/retrained_labels.txt \
   --architecture="${ARCHITECTURE}" \
   --image_dir=tensorflow/projects/retrain_tutorial/train_clothing/ \
```
A quick 4000 steps of retraining later and we're in business... The final metrics for the model all seem to indicate that it has learned to classify well.
```python
Step 3999: Train accuracy = 99.0%
Step 3999: Cross entropy = 0.029330
Step 3999: Validation accuracy = 94.0% (N=100)
Final test accuracy = 93.5% (N=62)
```

## Evaluation

This is where the going gets interesting. To test how well the predictions from this classifier generalized to non-training images, I pulled photos from a few other web stores, some personal photos, and some Google image searches. I wanted to test how well the classifier worked on images that looked similar to the training set, but also to see how well it worked on more ambiguous photos to try and throw the classifier off.

To run evaluation, I ran the label_image script and specified the paths to the retrained graph as well as the retrained labels. The most important argument after that is to specify the location of the image that I wanted to classify.
```
python label_image.py 
--graph=retrain_tutorial/tmp/retrained_graph.pb 
--labels=retrain_tutorial/tmp/retrained_labels.txt 
--input_layer=Placeholder 
--output_layer=final_result 
--image=retrain_tutorial/test_clothing/*IMAGE NAME* 
```

## Results

Okay, let's get into some examples. First I gave the classifier a few softballs, starting with some stock photos that used plain backgrounds like our training images. The label_image script returns the score for each label, which can be interpreted as the 'confidence' of the prediction. A score of 0.99 indicates the classifier is almost certain the image comes from that category. 

![mr porter shoes](https://lh3.googleusercontent.com/yw6lo8VkPnI3fOJyAcO_Anx1w5aDwOKnXHYTIGdCozKpUji_ZyBeVg4rwGT2X_tvhygMnYlMq2bP)
```
shoes 0.9995609
belts 0.00025920972
tops 6.553035e-05
outerwear 5.454674e-05
suits 3.0018897e-05
```
![mr porter pants](https://lh3.googleusercontent.com/CwxuaxgktapGzcH0YBOROVo5kNtWIKTqo3P6r9YoQgQJepTLcZdK4drR1Qik1YSGGmsVlcf1_3-L)
```
pants 0.6770167
shoes 0.18507263
belts 0.040040944
outerwear 0.037622742
tops 0.031976786
```
![namu shirt](https://lh3.googleusercontent.com/rANmydPOpXFp4ZpdT9te-Uymxlrdms97ROf5u_ey78tvRo1EERYJ3xKEXMAT0ao_0K-FZnn55mfU)
```
tops 0.99459165
outerwear 0.005243357
pants 0.00014370387
shoes 2.067295e-05
suits 6.462093e-07
```
The retrained model does an excellent job of classifying clothing categories of images. Most impressive to me is that it does a good job identifying pants and shoes in the second photo. This established a good baseline of what the classifier was capable of. Next I sought to test the model with some more difficult and realistic images. I took some personal photos of mine and cropped them to focus on one specific clothing item.

![my shirt](https://lh3.googleusercontent.com/E8qU2nsWxdgD2ysAIWkmxS4zi1cwvjbyuCrhvw4N8zjeQ9fYL3667CVvmfnJGXsl0-Bbw6bUyYSv)
```python
tops 0.6243893
outerwear 0.26041698
suits 0.04839059
shoes 0.04195948
belts 0.018166095
```
![my coat](https://lh3.googleusercontent.com/Mf2FdUAzt3OhW1bf8GaQQfLZxvkwbpzVJQHqdtLklt3vPbJHiaGBg1JCAv5qvX5d707ebzS2dPTC)
```python
outerwear 0.99180025
tops 0.0056323675
suits 0.0020895004
shoes 0.00030350732
belts 0.00015142947
```

The model handled everything with ease until I reached this last image. 

![my pants](https://lh3.googleusercontent.com/aLY_4Cs4OxHDGq3kIWwmR-VGMu4-Xih1U5nFws2wUtBw6_AJwKOHe_R1e4xFat9FJnSCqi6XUOlX)
```
outerwear 0.9896455
shoes 0.008882833
pants 0.0012335232
tops 0.00019269527
suits 4.5536905e-05
```
That's odd... I'm not really sure what has the classifier so mixed up with my pants. One consideration might be that I need to crop my shirt out more aggressively.

Finally, I threw some photos of full outfits at the classifier to see how the classifier allocated probabilities across the different categories. First, I passed a picture of the ever stylish Jeff Goldblum. To be honest, I was confused about why shoes had such a high probability in this photo until I looked in the background!

![](https://lh3.googleusercontent.com/uWviyyPLv-thXhDLIeeWF6F7JP7YSdx1OqRZ_UhFeSdQ886LK_NJ3RSZ-ctl2CVGKUE2wMKQqQ_v "Jeff")
```
outerwear 0.6135582
shoes 0.14796199
tops 0.14606433
belts 0.06639394
suits 0.02115087
```
The classifier also does well in picking out Aziz Ansari's shoes and suit.

![aziz](https://lh3.googleusercontent.com/WVCafGiqMsBJsK6d6ZyRAedeT1zHrH_9pcB0qbeUuCPbbfapbmhpQQMN1Xd8KCZVHmluQKcRNvtu)
```
shoes 0.5839953
suits 0.3240096
belts 0.05522267
outerwear 0.018567573
pants 0.013392047
```
It also can pick out Jon Hamm's henley with high certainty. 
![jon hamm](https://lh3.googleusercontent.com/1LcIQK7em14z7wQFVIiL2UX44mrUfiepOe7xlcyiXv3dCY3hOScJv0NvLvWMSo12utZuIoNjoCTw)
```python
tops 0.9203238
shoes 0.064956225
outerwear 0.009644174
pants 0.0042796866
suits 0.0007960808
```

All in all, this was a fun couple of hours playing around with TensorFlow and image classification. Although I didn't do any coding, I got a chance to learn more about how image classifiers are built in TensorFlow and saw the power of pre-trained models in person. This has encouraged me to try and build a small classifier that I will hopefully write about in another post soon!