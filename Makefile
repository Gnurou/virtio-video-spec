all: main.pdf

main.pdf: virtio-video.tex
	latexmk -xelatex main.tex

virtio-video.tex: virtio-video.md
	pandoc --lua-filter virtio.lua --listings $< -t latex >$@

clean:
	rm virtio-video.tex main.pdf main.aux
