source(system.file("doc/metr-model.R", package="bmetr"))
library(patchwork)

# comparative + corrections
p.comparative <- ggplot(comparative) +
  aes(mark, drop_errors(value), color=series) +
  ggthemes::geom_rangeframe(aes(y=drop_errors(bpm)), data=neewer, color="black") +
  geom_abline(slope=1, color="gray") + geom_point(size=.7) +
  geom_errorbar(aes(ymin=errors_min(value), ymax=errors_max(value)), size=.3) +
  geom_smooth(method="gam", size=.3, se=FALSE) +
  labs(x="Metronome mark [bpm]", y="Oscillation frequency [bpm]", color=NULL) +
  theme(legend.position=c(0, 1), legend.justification=c(0, 1),
        axis.title.y=element_text(hjust=0.2), axis.title.x=element_text(hjust=0.5))

p.corrections <- ggplot(corrections) +
  aes(mark, drop_errors(value), color=series) +
  ggthemes::geom_rangeframe(color="black") +
  geom_point(size=.7) +
  geom_errorbar(aes(ymin=errors_min(value), ymax=errors_max(value)), size=.3) +
  geom_smooth(method="gam", size=.3, se=FALSE) +
  labs(x="Metronome mark [bpm]", y="Correction [%]", color="") +
  theme(legend.position=c(1, 0), legend.justification=c(1, 0))

p.comparative + p.corrections + plot_annotation(tag_levels="a") &
  theme(plot.tag=element_text(face="bold"))
ggsave("Fig8.eps", width=178, height=75, units="mm", scale=1.6, device=cairo_ps)

# pred + fit
p.pred <- ggplot(pred) +
  aes(drop_errors(r), y, color=reorder(model, drop_errors(r), min)) +
  ggthemes::geom_rangeframe(color="black") +
  geom_point(size=.7) +
  geom_errorbarh(aes(xmin=errors_min(r), xmax=errors_max(r)), height=2, size=.3) +
  geom_line(aes(y=fit), size=.3) +
  scale_color_discrete(labels=labels) +
  labs(x="r [mm]", y=expression(Omega^2), color=NULL) +
  theme(legend.position=c(1, 1), legend.justification=c(1, 1))

p.fit <- ggplot(fit) +
  aes(drop_errors(M.), drop_errors(mu.), color=reorder(model, -drop_errors(mu.))) +
  ggthemes::geom_rangeframe(color="black") +
  geom_point(size=.7) +
  geom_point(aes(shape=model), data=note, color="black", size=2) +
  geom_errorbarh(aes(xmin=errors_min(M.), xmax=errors_max(M.)), height=.005, size=.3) +
  geom_errorbar(aes(ymin=errors_min(mu.), ymax=errors_max(mu.)), width=.012, size=.3) +
  scale_shape_manual(name=NULL, values=8) +
  labs(x="Nondimensionalized lower mass", y="Nondimensionalized rod mass", color=NULL) +
  guides(color=guide_legend(order=1), shape=guide_legend(order=2)) +
  theme(legend.position=c(.95, .95), legend.justification=c(1, 1), legend.spacing.y=unit(-2, "mm"))

p.pred + p.fit + plot_annotation(tag_levels="a") &
  theme(plot.tag=element_text(face="bold"))
ggsave("Fig9.eps", width=178, height=75, units="mm", scale=1.6, device=cairo_ps)
