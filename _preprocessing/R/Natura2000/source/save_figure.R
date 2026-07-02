# Function to save figures using multiple devices
save_figure <- function(plot, file, path = ".", devices = "png", ...) {
  sapply(devices, function(dev) {
    ggplot2::ggsave(
      filename = paste0(file.path(path, file), ".", dev),
      plot = plot,
      ...
    )
  })
}
