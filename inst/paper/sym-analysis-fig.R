source(system.file("doc/sym-analysis.R", package="bmetr"))
library(patchwork)

# data cleaning example + distribution by conductor
p.cleaning <- wrap_plots(g, h, nrow=1, widths=c(5, 1.5)) +
  plot_annotation(theme=theme(plot.margin=margin(11, 11, 0, 6.5)))

p.conductors <- dt.window %>%
  mutate(ptype = droplevels(ptype, "Romantic")) %>%
  mutate(conductor = `levels<-`(
    conductor, sapply(strsplit(levels(conductor), ","), "[", 1))) %>%
  ggplot() + aes(tempo - mark, conductor) +
  ggridges::geom_density_ridges(
    aes(fill=ptype), color="lightgray", size=0.3,
    quantile_lines=TRUE, quantiles=2, vline_color="white") +
  geom_vline(xintercept=0, color="black") +
  scale_fill_discrete(breaks=rev(levels(factor(dt.window$ptype)))) +
  scale_y_discrete(position="right") + xlim(-40, 20) +
  labs(y=NULL, x="Tempo difference [bpm]", fill=NULL) +
  theme(legend.position=c(0, 1.02), legend.justification=c(0, 1),
        legend.key.size=unit(5, "pt"), legend.title=element_text(size=10),
        legend.text=element_text(size=8),
        axis.ticks.y=element_blank(),
        panel.grid.major.y=element_line(color="lightgray", size=0.3))

p.main <- wrap_elements(full=p.cleaning) +
  p.conductors + plot_layout(widths=c(6.5, 2.5)) +
  plot_annotation(tag_levels="a") & theme(plot.tag=element_text(face="bold"))

gb <- ggplot() + theme_void() +
  annotate("text", 0, 0, label="b", fontface="bold", size=4.8)
gc <- ggplot() + theme_void() +
  annotate("text", 0, 0, label="c", fontface="bold", size=4.8)
gd <- ggplot() + theme_void() +
  annotate("label", 0, 0, label="d", fontface="bold", size=4.8, label.size=0)
ggplot() + theme_void() + xlim(0, 1) + ylim(0, 1) +
  annotation_custom(patchworkGrob(p.main)) +
  annotation_custom(ggplotGrob(gb), -Inf, -0.01, 0.3, 0.35) +
  annotation_custom(ggplotGrob(gc), -Inf, -0.01, 0.13, 0.2) +
  annotation_custom(ggplotGrob(gd), 0.63, 0.75, 0.94, Inf)
ggsave("Fig2.eps", width=178, height=75, units="mm", scale=1.6, device=cairo_ps)

# validation
p.val.conductor <- ggplot(dt.val.conductor) +
  aes(window, sample) + ggthemes::geom_rangeframe() +
  geom_abline(color="lightgray") +
  geom_point(aes(color=ptype)) + geom_smooth(method=lm, formula=y~x) +
  ggpmisc::stat_poly_eq(formula=y~x, parse=TRUE) +
  scale_color_discrete(breaks=levels(factor(dt.val.conductor$ptype))) +
  labs(x="Main data set", y="Validation data set", color=NULL,
       subtitle="Median tempo difference by conductor [bpm]") +
  theme(legend.position=c(1, 0), legend.justification=c(1, 0))

p.val.mark <- ggplot(dt.val.mark) +
  aes(window, sample) + ggthemes::geom_rangeframe() +
  geom_abline(color="lightgray") +
  geom_point() + geom_smooth(method=lm, formula=y~x) +
  ggpmisc::stat_poly_eq(formula=y~x, parse=TRUE) +
  labs(x="Main data set", y="Validation data set",
       subtitle="Median tempo by mark [bpm]") +
  theme(legend.position=c(0, 1), legend.justification=c(0, 1))

p.val.conductor + p.val.mark + plot_annotation(tag_levels="a") &
  theme(plot.tag=element_text(face="bold"))
ggsave("Fig6.eps", width=178, height=75, units="mm", scale=1.6, device=cairo_ps)

# regressions
ggplot(dt.medians) +
  aes(mark, tempo) + facet_grid(.~ptype) +
  ggthemes::geom_rangeframe(color="black") +
  geom_abline(color="lightgray") +
  geom_violin(aes(group=mark), dt.window, scale="width", color="lightgray") +
  geom_point() + geom_point(data=dt.exception, shape=1) +
  geom_ribbon(aes(ymin=lwr, ymax=upr), alpha=.2) +
  geom_line(aes(y=fit), color="blue") +
  geom_text(aes(label=label), perf, hjust=1, parse=TRUE) +
  labs(x="Metronome mark [bpm]", y="Performed tempo [bpm]") +
  theme(legend.position=c(0, 1), legend.justification=c(0, 1))

ggsave("Fig3.eps", width=178, height=75, units="mm", scale=1.6, device=cairo_ps)

# distortions
d1 <- p + ylim(0, 150) +
  scale_color_gradient(breaks=c(0, -4, -8), name="Variation of R [mm] vs.") +
  annotate("text", 85, 150, label="Romantic average", hjust=0, color="red") +
  theme(axis.text.x=element_blank(), axis.title.x=element_blank()) +
  stat_function(fun=metr_model_bias, args=list(
    R=c(R, R-2), M.=M., l=l, mu.=mu., A=A), aes(color=-2)) +
  stat_function(fun=metr_model_bias, args=list(
    R=c(R, R-5), M.=M., l=l, mu.=mu., A=A), aes(color=-5)) +
  stat_function(fun=metr_model_bias, args=list(
    R=c(R, R-8), M.=M., l=l, mu.=mu., A=A), aes(color=-8))

d2 <- p + ylim(0, 150) +
  scale_color_gradient(breaks=c(0, -10, -15), name="Variation of M [%]") +
  theme(axis.text=element_blank(), axis.title=element_blank()) +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=c(M., M.-0.05*M.), l=l, mu.=mu., A=A), aes(color=-5)) +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=c(M., M.-0.10*M.), l=l, mu.=mu., A=A), aes(color=-10)) +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=c(M., M.-0.15*M.), l=l, mu.=mu., A=A), aes(color=-15))

d3 <- p + ylim(0, 150) +
  scale_color_gradient(breaks=c(0, 20, 40), trans="reverse", name="Variation of inclination [°]") +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=M., l=l, mu.=mu., A=A, g=9.807*c(1, cos(10*pi/180))), aes(color=10)) +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=M., l=l, mu.=mu., A=A, g=9.807*c(1, cos(25*pi/180))), aes(color=25)) +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=M., l=l, mu.=mu., A=A, g=9.807*c(1, cos(40*pi/180))), aes(color=40))

d4 <- p + ylim(0, 150) +
  scale_color_gradient(breaks=c(0, 12, 16), trans="reverse", name="Scale shift [mm]") +
  theme(axis.text.y=element_blank(), axis.title.y=element_blank()) +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=M., l=l, mu.=mu., A=A, shift=8), aes(color=8)) +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=M., l=l, mu.=mu., A=A, shift=12), aes(color=12)) +
  stat_function(fun=metr_model_bias, args=list(
    R=R, M.=M., l=l, mu.=mu., A=A, shift=16), aes(color=16))

d <- d1 + d2 + d3 + d4 + plot_annotation(tag_levels="a") &
  theme(plot.tag=element_text(face="bold"))
ggsave("Fig10.eps", d, width=178, height=150, units="mm", scale=1.6, device=cairo_ps)
