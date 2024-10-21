
# Produces a bar plot of the benchmark

data = data.frame(
  model =colnames(pr_table),
  Precision = pr_table[1,],
  Recall = pr_table[2,]
)



# Reshape the data to a long format
data_long <- reshape2::melt(data, id.vars = "model", variable.name = "Metric", value.name = "Value")

data_long$model = factor(data_long$model, levels=colnames(pr_table))

library(ggplot2)

# Adjust y-axis labels and breaks
ggplot(data_long, aes(x = model, y = ifelse(Metric == "Precision", Value * 2, -Value), fill = Metric)) +
  geom_bar(stat = "identity", position = "identity", width = 0.5) +
  scale_y_continuous(labels = function(x) ifelse(x < 0, abs(x), x / 2), breaks = seq(-1, 3, by = 0.2),limits=c(-1,2)) +
  labs(x = "Model", y = "Value") +
  scale_fill_manual(values = c("Precision" = "#32CD32", "Recall" = "#00AAFF")) +
  theme_minimal() +
  theme(
    axis.title.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
    axis.text.y = element_text(size = 10),
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    plot.title = element_text(size = 18),
    plot.subtitle = element_text(size = 16),
    plot.caption = element_text(size = 12)
  )
