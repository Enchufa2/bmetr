#' Metronomes Data
#'
#' Measurements of five models of metronome: \code{Neewer}, \code{Neewer (photo)},
#' \code{Patent}, \code{TB 06} and \code{TB 07}. The first two correspond to a
#' contemporary metronome, a Neewer NW-707. The difference is that \code{Neewer}
#' corresponds to precise direct measurements in a dismantled metronome, while
#' \code{Neewer (photo)} measurements were taken from a photograph. The rest of
#' the models follow this methodology. The third one, \code{Patent}, corresponds
#' to the original diagram from Maelzel's 1815 English patent. Finally,
#' \code{TB 06} and \code{TB 07} are metronomes number 6 and 7, respectively,
#' from Tony Bingham's collection (see the references).
#'
#' @references Bingham, T. and Turner, A. (2017) \emph{Metronomes and Musical
#' Time: Catalogue of the Tony Bingham Collection at the exhibition AUF TAKT!
#' Held in the Museum für Musik, Basel}. London. ISBN: 978-0-946113-11-8.
#'
#' @format
#' \bold{\code{metr.neewer}} provides oscillation frequency measurements for the
#' \code{Neewer} metronome.
#' \tabular{ll}{
#'   \code{mark}    \tab metronome mark, in pulses per minute. \cr
#'   \code{bpm}     \tab measured frequency, in pulses per minute. \cr
#'   \code{bpm.se}  \tab standard error of \code{bpm}, in the same units.
#' }
#'
#' @name metr.data
"metr.neewer"

#' @format
#' \bold{\code{metr.marks}} provides position measurements of each metronome
#' mark for all the metronomes.
#' \tabular{ll}{
#'   \code{model}   \tab metronome model. \cr
#'   \code{mark}    \tab metronome mark, in pulses per minute. \cr
#'   \code{r}       \tab distance from the shaft to the mark, in mm. \cr
#'   \code{r.se}    \tab standard error of \code{r}, in the same units.
#' }
#'
#' @name metr.data
"metr.marks"

#' @format
#' \bold{\code{metr.params}} provides measurements of fixed dimensions for all
#' the metronomes. All the additional columns suffixed with \code{.se} are the
#' standard errors of the corresponding variables in the same units.
#' \tabular{ll}{
#'   \code{model}   \tab metronome model. \cr
#'   \code{rcm}     \tab position of the center of mass of the upper mass with
#'                       respect to the metronome mark, in mm. \cr
#'   \code{l}       \tab length of the rod over the shaft, in mm. \cr
#'   \code{R}       \tab distance from the shaft to the center of mass of the
#'                       lower mass, in mm. \cr
#'   \code{L}       \tab length of the rod below the shaft, in mm. \cr
#'   \code{A}       \tab oscillation amplitude, in degrees.
#' }
#'
#' @name metr.data
"metr.params"

#' Beethoven's Symphonies Data
#'
#' Six data sets with tempo measurements plus additional information about
#' Beethoven's nine symphonies.
#' \itemize{
#'   \item Data sets \code{sym.marks}, \code{sym.recordings} and \code{sym.duration}
#'   provide detailed information about Beethoven's annotations as well as the
#'   recordings selected for this study (the complete symphonies from 36 different
#'   conductors).
#'   \item Data sets \code{sym.window}, and \code{sym.sample}
#'   provide tempo measurements extracted using the Marsyas framework (and the
#'   tempo estimation algorithm by Percival and Tzanetakis; see the references)
#'   and distinct methodologies.
#' }
#'
#' @references
#' Tzanetakis, G. and Cook, P. (2000) "MARSYAS: a framework for audio analysis."
#' \emph{Organised Sound}, 4(3):169-175
#'
#' Percival, G. and Tzanetakis, G. (2013) "An effective, simple tempo estimation
#' method based on self-similarity and regularity." \emph{IEEE International
#' Conference on Acoustics, Speech and Signal Processing}, 241-245.
#'
#' Percival, G. and Tzanetakis, G. (2014) "Streamlined Tempo Estimation Based on
#' Autocorrelation and Cross-correlation with Pulses." \emph{IEEE/ACM Trans.
#' Audio, Speech and Lang. Proc.}, 22(12):1765-1776.
#'
#' @format
#' \bold{\code{sym.marks}} provides complete timing information extracted from
#' Beethoven's scores: character annotations, tempo markings, beats and bars for
#' the nine symphonies. Note that some movements have several character
#' annotations (more than one section).
#' \tabular{ll}{
#'   \code{symphony}  \tab symphony number. \cr
#'   \code{movement}  \tab movement number. \cr
#'   \code{character} \tab character annotation in this section. \cr
#'   \code{mark}      \tab metronome mark. \cr
#'   \code{beat}      \tab beats per bar. \cr
#'   \code{bar.tot}   \tab total number of bars in this section. \cr
#'   \code{bar.rep}   \tab total number of repeated bars in this section. \cr
#'   \code{bar.1}     \tab total number of bars in first repetition boxes. \cr
#'   \code{tsig}      \tab time signature, as expected by
#'                         \code{\link{tmp_rectify_tsig}} \cr
#'   \code{section}   \tab convenience section identifier (one per character).
#' }
#' Therefore, the theoretical duration, in minutes, \emph{without repetitions}
#' for each section can be computed as follows:
#' \code{(bar.tot - bar.1) * beat / mark}.
#' And the theoretical duration, in minutes, \emph{with repetitions} is just the
#' previous value \code{+ bar.rep * beat / mark}.
#'
#' @name sym.data
"sym.marks"

#' @format
#' \bold{\code{sym.recordings}} provides complete information about the albums
#' analyzed in this work (the nine symphonies for 36 different conductors).
#' \tabular{ll}{
#'   \code{conductor} \tab conductor's name. \cr
#'   \code{orchestra} \tab orchestra(s)'s name. \cr
#'   \code{title}     \tab album title. \cr
#'   \code{label}     \tab album label. \cr
#'   \code{upc}       \tab Universal Product Code. \cr
#'   \code{date}      \tab recording dates. \cr
#'   \code{year}      \tab release date. \cr
#'   \code{ptype}     \tab performance type: romantic, Historically Informed
#'                         (HI) or under HI influence.
#' }
#'
#' @name sym.data
"sym.recordings"

#' @format
#' \bold{\code{sym.duration}} provides performed duration (track length) for the
#' nine symphonies and 36 different conductors.
#' \tabular{ll}{
#'   \code{symphony}  \tab symphony number. \cr
#'   \code{movement}  \tab movement number. \cr
#'   \code{conductor} \tab conductor's name. \cr
#'   \code{duration}  \tab track length, in seconds.
#' }
#'
#' @name sym.data
"sym.duration"

#' @format
#' \bold{\code{sym.window}} provides continuous tempo measurements per symphony,
#' movement and conductor by means of a sliding window.
#' \tabular{ll}{
#'   \code{symphony}  \tab symphony number. \cr
#'   \code{movement}  \tab movement number. \cr
#'   \code{conductor} \tab conductor's name. \cr
#'   \code{n}         \tab sample index. Samples with \code{n=0} correspond to
#'                         an estimation for the entire track. \cr
#'   \code{start}     \tab start time for the sliding window, in seconds. \cr
#'   \code{duration}  \tab window length, in seconds. \cr
#'   \code{tempo}     \tab estimated tempo.
#' }
#'
#' @name sym.data
"sym.window"

#' @format
#' \bold{\code{sym.sample}}, in contrast to \code{sym.window}, provides a single
#' tempo estimation for each symphony, movement and conductor. The sample was
#' collected at the end of each track (the "coda" of the movement), where the
#' tempo is arguably more stable. It has the same variables as \code{sym.window},
#' except for \code{n}. Instead, \code{sym.sample} contains a \code{section}
#' column to identify the section from which the tempo was sampled. This section
#' identifier corresponds to the homonymous one present in \code{sym.marks}.
#'
#' @name sym.data
"sym.sample"
