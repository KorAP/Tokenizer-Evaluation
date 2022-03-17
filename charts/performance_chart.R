#!/bin/env Rscript
library(tidyverse)
library(idsThemeR) # install_git("https://korap.ids-mannheim.de/gerrit/IDS-Mannheim/idsThemeR")
library(extrafont)

df <- read_tsv("performance.tsv")
df %>%
  fill(Tool) %>%
  mutate(order_by = pmax(.[[6]], .[[7]])) %>%
  filter(Tool!="wc", !is.na(order_by)) %>%
  pivot_longer(cols=c(7, 6)) %>%
  mutate(name=str_replace_all(name, "Tokens/ms effi", "")) %>%
  mutate(tool = paste0(Tool, if_else(is.na(Model), "", paste0(" (", Model, ")")))) %>%
  { df2 <<- . } %>%
  mutate(Tool= factor(tool) %>% fct_reorder(order_by)) %>%
  ggplot(aes(x=Tool, y=value, fill=forcats::fct_rev(name))) +
  geom_col(position="dodge") +
  ylab("Tokens / ms") +
  xlab(NULL) +
  coord_flip() +
  theme_ids(style="light") +
  theme(legend.position="bottom", legend.title = element_blank()) +
  scale_fill_ids(palette = "d3")

ggsave("tok_perf.png", width = 70 * .pt, height = 40 *.pt, units = "mm", dpi = 600)
ggsave("tok_perf.pdf", device = cairo_pdf, width = 70 * .pt, height = 40 *.pt, units = "mm", dpi = 600)
