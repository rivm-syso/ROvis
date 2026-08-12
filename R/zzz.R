.onAttach <- function(...) {
  dara_pkgs <- c("ROvis.utils", "ROvis.table", "ROvis.plotly", "ROvis.shiny", "ROvis.echarts", "ROvis.ggplot2")

  lapply(dara_pkgs, library, character.only = TRUE)

  # Write a start-up message indicating which packages were attached

  header <- rule(
    left = style_bold("Attached ROvis packages"),
    right = paste0("ROvis ", as.character(utils::packageVersion("ROvis")))
  )

  versions <- map_chr(dara_pkgs, utils::packageDescription, fields = "Version")

  packages <- paste0(
    col_green(cli::symbol$tick),
    " ",
    col_blue(format(dara_pkgs)),
    "   ",
    ansi_align(versions, max(ansi_nchar(versions))),
    " "
  )

  msg <- paste0(header, "\n", paste(packages, collapse = "\n"))

  inform(message = msg, class = "packageStartupMessage")
}
