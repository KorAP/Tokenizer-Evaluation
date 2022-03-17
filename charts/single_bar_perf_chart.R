df <- read_tsv("performance.tsv")
ylabel <- colnames(df)[7]
colnames(df)[7] <- "perf"
df %>% 
  fill(Tool) %>%
  filter(Tool!="wc", !is.na(perf)) %>%
  arrange(desc(perf)) %>%
  mutate(tool = paste0(Tool, if_else(is.na(Model), "", paste0(" (", Model, ")")))) %>%
  mutate(Tool= factor(tool) %>% fct_reorder(perf)) %>%
  ggplot(aes(x=Tool, y=perf)) + 
  geom_col() + 
  ylab("Tokens/ms") +
  xlab(NULL) +
  coord_flip()# +
#  geom_text(aes(label=perf), position=position_stack(vjus=0.5), hjust=0.25)
#ggsave("/tmp/tok_perf.png", width = 70 * .pt, height = 40 *.pt, units = "mm", dpi = 600)
