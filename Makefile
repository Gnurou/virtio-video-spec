all: main.pdf

main.pdf: virtio-video.tex
	latexmk -xelatex main.tex

virtio-video.tex: virtio-video.md
	# The sed command removes escape backslashes before underscores if the preceding character is capitalized.
	# This allows us to keep the underscores in math formulas escaped. Not perfect but works for us.
	pandoc --lua-filter virtio.lua --listings $< -t latex | sed 's/\([A-Z]\)\\_/\1_/g' >$@

clean:
	rm virtio-video.tex main.pdf main.aux
