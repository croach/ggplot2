GeomErrorbar <- proto(Geom, {
  objname <- "errorbar"
  desc <- "Error bars"
  icon <- function(.) {
    gTree(children=gList(
      segmentsGrob(c(0.3, 0.7), c(0.3, 0.5), c(0.3, 0.7), c(0.7, 0.9)),
      segmentsGrob(c(0.15, 0.55), c(0.3, 0.5), c(0.45, 0.85), c(0.3, 0.5)),
      segmentsGrob(c(0.15, 0.55), c(0.7, 0.9), c(0.45, 0.85), c(0.7, 0.9))
    ))
  }
  
  default_stat <- function(.) StatIdentity
  default_aes <- function(.) aes(colour = "black", size=0.5, linetype=1, width=0.5)
  guide_geom <- function(.) "path"
  required_aes <- c("x", "ymin", "ymax")
  
  reparameterise <- function(., df, params) {
    df$width <- df$width %||% 
      params$width %||% (resolution(df$x, FALSE) * 0.9)
        
    transform(df,
      xmin = x - width / 2, xmax = x + width / 2, width = NULL
    )
  }

  seealso <- list(
    "geom_pointrange" = "range indicated by straight line, with point in the middle",
    "geom_linerange" = "range indicated by straight line",
    "geom_crossbar" = "hollow bar with middle indicated by horizontal line",
    "stat_summary " = "examples of these guys in use",
    "geom_smooth" = "for continuous analog"
  )

  draw <- function(., data, scales, coordinates, width = NULL, ...) {
    GeomPath$draw(with(data, data.frame( 
      x = as.vector(rbind(xmin, xmax, x,    x,    xmin, xmax)), 
      y = as.vector(rbind(ymax, ymax, ymax, ymin, ymin, ymin)),
      colour = rep(colour, each = 6),
      size = rep(size, each = 6),
      linetype = rep(linetype, each = 6),
      group = rep(1:(nrow(data)), each=6),
      stringsAsFactors = FALSE, 
      row.names = 1:(nrow(data) * 6)
    )), scales, coordinates, ...)
  }
  
  examples <- function(.) {
    # Create a simple example dataset
    df <- data.frame(
      trt = factor(c(1, 1, 2, 2)), 
      resp = c(1, 5, 3, 4), 
      group = factor(c(1, 2, 1, 2)), 
      se = c(0.1, 0.3, 0.3, 0.2)
    )
    df2 <- df[c(1,3),]
    
    # Define the top and bottom of the errorbars
    limits <- aes(ymax = resp + se, ymin=resp - se)
    
    p <- ggplot(df, aes(fill=group, y=resp, x=trt))
    p + geom_bar(position="dodge", stat="identity")
    
    # Because the bars and errorbars have different widths
    # we need to specify how wide the objects we are dodging are
    dodge <- position_dodge(width=0.9)
    p + geom_bar(position=dodge) + geom_errorbar(limits, position=dodge, width=0.25)
    
    p <- ggplot(df2, aes(fill=group, y=resp, x=trt))
    p + geom_bar(position=dodge)
    p + geom_bar(position=dodge) + geom_errorbar(limits, position=dodge, width=0.25)

    p <- ggplot(df, aes(colour=group, y=resp, x=trt))
    p + geom_point() + geom_errorbar(limits, width=0.2)
    p + geom_pointrange(limits)
    p + geom_crossbar(limits, width=0.2)

    # If we want to draw lines, we need to manually set the
    # groups which define the lines - here the groups in the 
    # original dataframe
    p + geom_line(aes(group=group)) + geom_errorbar(limits, width=0.2)    
  }
})

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}
