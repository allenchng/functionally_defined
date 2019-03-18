library(ggplot2)
library(dplyr)
library(gganimate)
library(readr)
library(lubridate)
library(ggimage)

#### data ####
data <- read_csv('data/time_series_animation/three_threads.csv') %>%
  select(-X1) %>%
  mutate(thread = replace(thread, thread == 'John Elliot', 'John Elliott'))

#### pictures ####
john <- '../john.png'
foo <- '../foo.gif'
kyle <- '../kyle.png'

post_data <- data %>%
  select(thread.post, user, mdy, thread) 

post_data$mdy <- as.Date(post_data$mdy, "%b %d, %Y")

post_month_year <- post_data %>%
  mutate(month_date = floor_date(post_data$mdy, unit = 'month')) %>%
  group_by(month_date, thread) %>%
  summarise(total.posts = n())

#### PLOTS ####

combined_anim <- post_month_year %>%
  ggplot(aes(month_date, total.posts, group = thread, color = thread)) +
  geom_line() +
  geom_segment(aes(xend = as.Date('2019-03-01'), 
                   yend = total.posts), linetype = 2, colour = 'grey') +
  geom_text(aes(x = as.Date('2019-03-01'), 
                label = thread), hjust = 0) + 
  geom_point(size = 2) + 
  coord_cartesian(clip = 'off') +
  scale_x_date(breaks = '1 year', date_labels = '%Y') +
  labs(title = "Monthly Posts Per Thread",
       subtitle = "Time:{frame_along}",
       x = "Date", y = 'Total Posts (Monthly)')+
  theme_minimal() + 
  theme(legend.position = 'none',
    plot.margin = margin(5.5, 90, 5.5, 5.5),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 12),
    plot.title = element_text(size = 15),
    plot.subtitle = element_text(size = 12)) +
  transition_reveal(month_date)

facet_anim <- post_month_year %>%
  ggplot(aes(month_date, total.posts)) +
    geom_line() +
    geom_point(size = 2) +
    facet_wrap(~thread) +
    transition_reveal(month_date) +
    theme_minimal()
  
je <- post_month_year %>%
  filter(thread == 'John Elliott') %>%
  ungroup() %>%
  mutate(image = rep(c(john), nrow(.)))

slp <- post_month_year %>%
  filter(thread == 'Saint Laurent Paris') %>%
  ungroup() %>%
  mutate(image = rep(c(foo), nrow(.)))

nmwa <- post_month_year %>%
  filter(thread == 'No Man Walks Alone') %>%
  ungroup() %>%
  mutate(image = rep(c(kyle), nrow(.)))

slp_anim <- slp %>%
  ggplot(aes(month_date, total.posts)) +
  geom_line() +
  geom_image(aes(image=image), size=.08) +
  geom_vline(aes(xintercept = as.Date("2016-04-01")),
             color = 'red', lty = 2) +
  geom_vline(aes(xintercept = as.Date("2018-01-01")),
             color = 'blue', lty = 2) +
  coord_cartesian(clip = 'off') +
  scale_x_date(breaks = '1 year', date_labels = '%Y') +
  labs(title = "Monthly Posts in the SLP Thread",
       subtitle = "Time:{frame_along}",
       x = "Date", y = 'Total Posts (Monthly)')+
  theme_minimal() + 
  theme(legend.position = 'none',
        plot.margin = margin(5.5, 90, 5.5, 5.5),
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 12),
        plot.title = element_text(size = 15),
        plot.subtitle = element_text(size = 12)) +
  transition_reveal(month_date)

nmwa_anim <- nmwa %>%
  ggplot(aes(month_date, total.posts)) +
  geom_line() +
  geom_image(aes(image=image), size=.08) +
  coord_cartesian(clip = 'off') +
  scale_x_date(breaks = '1 year', date_labels = '%Y') +
  labs(title = "Monthly Posts in the NMWA Thread",
       subtitle = "Time:{frame_along}",
       x = "Date", y = 'Total Posts (Monthly)')+
  theme_minimal() + 
  theme(legend.position = 'none',
        plot.margin = margin(5.5, 90, 5.5, 5.5),
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 12),
        plot.title = element_text(size = 15),
        plot.subtitle = element_text(size = 12)) +
  transition_reveal(month_date)

je_anim <- je %>%
  ggplot(aes(month_date, total.posts)) +
  geom_line() +
  geom_image(aes(image=image), size=.08) +
  coord_cartesian(clip = 'off') +
  scale_x_date(breaks = '1 year', date_labels = '%Y') +
  labs(title = "Monthly Posts in the JE Thread",
       subtitle = "Time:{frame_along}",
       x = "Date", y = 'Total Posts (Monthly)')+
  theme_minimal() + 
  theme(legend.position = 'none',
        plot.margin = margin(5.5, 90, 5.5, 5.5),
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 12),
        plot.title = element_text(size = 15),
        plot.subtitle = element_text(size = 12)) +
  transition_reveal(month_date)

#### ANIMATIONS ####
anim_save('combined_anim.gif', nframes = 200, fps=10)
anim_save('slp_anim.gif', nframes = 200, fps=10)
anim_save('nmwa_anim.gif', nframes = 200, fps=10)
anim_save('je_anim.gif', nframes = 200, fps=10)

animate(nmwa_anim, nframes = 120, fps=7)

