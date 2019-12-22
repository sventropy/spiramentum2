#!/bin/sh

rm -rf generated
mkdir generated

sips --resampleWidth 167 icon1024.png --out generated/icon167.png
sips --resampleWidth 152 icon1024.png --out generated/icon152.png
sips --resampleWidth 76 icon1024.png --out generated/icon76.png
sips --resampleWidth 80 icon1024.png --out generated/icon80.png
sips --resampleWidth 40 icon1024.png --out generated/icon40.png
sips --resampleWidth 58 icon1024.png --out generated/icon58.png
sips --resampleWidth 29 icon1024.png --out generated/icon29.png
sips --resampleWidth 20 icon1024.png --out generated/icon20.png
sips --resampleWidth 180 icon1024.png --out generated/icon180.png
sips --resampleWidth 120 icon1024.png --out generated/icon120.png
sips --resampleWidth 87 icon1024.png --out generated/icon87.png
sips --resampleWidth 60 icon1024.png --out generated/icon60.png
