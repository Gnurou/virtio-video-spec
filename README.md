# virtio-video spec RFC

This repository is used to prepare a patch for virtio-video protocol easily. It
includes a minimal set of LaTeX files from the [upstream
repository](https://github.com/oasis-tcs/virtio-spec) so a PDF document
containing only the video specification can be built quickly.

In order to make writing easier, the actual virtio-video spec is in the
virtio-video.md markdown file that is converted to LaTeX using the `virtio.lua`
pandoc filter.

## Build

```bash
$ make
```
