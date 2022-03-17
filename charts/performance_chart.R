library(tidyverse)
library(idsThemeR) # install_git("https://korap.ids-mannheim.de/gerrit/IDS-Mannheim/idsThemeR")

df <- read_tsv("performance.tsv")
df %>% 
  fill(Tool) %>%
  pivot_longer(cols=c(6,7)) %>%
  mutate(name=str_replace_all(name, "Tokens/ms ", "")) %>%
  filter(Tool!="wc", !is.na(value)) %>%
  { df2 <<- . } %>%
  arrange(desc(value)) %>%
  mutate(tool = paste0(Tool, if_else(is.na(Model), "", paste0(" (", Model, ")")))) %>%
  mutate(Tool= factor(tool) %>% fct_reorder(value)) %>%
  ggplot(aes(x=Tool, y=value, fill=forcats::fct_rev(name))) + 
  geom_col(position="dodge") + 
  ylab("Tokens / ms") +
  xlab(NULL) +
  coord_flip() + 
  theme_ids(style="light") +
  theme(legend.position="bottom") +
  scale_fill_ids(palette="mono") +
  scale_fill_discrete(name = "")

ggsave("/tmp/tok_perf.png", width = 70 * .pt, height = 40 *.pt, units = "mm", dpi = 600)
