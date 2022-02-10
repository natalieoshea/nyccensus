theme_census <- function(...) {
  theme_minimal() +
    theme(
      # set default text family, size, and color
      text = element_text(
        family = "Open Sans",
        size = 9,
        color = "grey20"
      ),
      # left align y axis labels
      axis.text.y = element_text(
        hjust = 0
      ),
      # adjust size and face of axis titles
      axis.title = element_text(
        size = 10,
        face = "italic",
      ),
      # add spacing above x axis title
      axis.title.x = element_text(
        margin = margin(10, 0, 0, 0)
      ),
      # add spacing to right of y axis title
      axis.title.y = element_text(
        margin = margin(0, 10, 0, 0)
      ),
      # set size and face of plot title
      plot.title = element_text(
        size = 12
      ),
      # set size of plot subtitle
      plot.subtitle = element_text(
        size = 10,
      ),
      # set size and justification of caption
      plot.caption = element_text(
        size = 8,
        hjust = 0,
        margin = margin(10, 0, 0, 0)
      ),
      # add margin around plot
      plot.margin = margin(10, 10, 10, 10),
      # set size of strip text
      strip.text = element_text(
        family = "Open Sans",
        size = 8.5,
        color = "grey20"
      ),
      # align title, subtitle, and captions with y-axis labels
      plot.title.position = "plot",
      plot.caption.position = "plot",
      ...
    )
}
