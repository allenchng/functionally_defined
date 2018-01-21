library(dplyr)
library(stringr)
library(tidyr)
library(reshape2)
library(ggplot2)
library(igraph)

raw <- readLines("test.txt")

lines <- data_frame(raw = raw) %>%
  filter(raw != "", !str_detect(raw, "(song)")) %>%
  mutate(is_scene = str_detect(raw, " Scene "),
         scene = cumsum(is_scene)) %>%
  filter(!is_scene) %>%
  separate(raw, c("speaker", "dialogue"), sep = ":", fill = "left", extra  = "drop") %>%
  group_by(scene, line = cumsum(!is.na(speaker))) %>%
  summarize(speaker = speaker[1], dialogue = str_c(dialogue, collapse = " "))

by_speaker_scene <- lines %>%
  count(scene, speaker) %>%
  filter(!is.na(speaker))

by_speaker_scene

speaker_scene_matrix <- by_speaker_scene %>%
  acast(speaker ~ scene, fun.aggregate = length)

norm <- speaker_scene_matrix / rowSums(speaker_scene_matrix)

h <- hclust(dist(norm, method = "manhattan"))

ordering <- h$labels[h$order]

scenes <- by_speaker_scene %>%
  filter(n() > 1) %>%        # scenes with > 1 character
  ungroup() %>%
  mutate(scene = as.numeric(factor(scene)),
         speaker = factor(speaker, levels = ordering))

ggplot(scenes, aes(scene, speaker)) +
  geom_point() +
  geom_path(aes(group = scene))
