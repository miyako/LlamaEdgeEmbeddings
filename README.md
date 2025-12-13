# LlamaEdgeEmbeddings
Local inference engine

[LlamgeEdge](https://llamaedge.com)+[llama-api-server](https://github.com/LlamaEdge/LlamaEdge/tree/main/llama-api-server).

* Removed [Stable Diffusion](https://github.com/LlamaEdge/sd-api-server) and [Whisper](https://github.com/LlamaEdge/whisper-api-server) plugins which are for Apple Silicon only.

## Dependencies

* [miyako/tcp](https://github.com/miyako/tcp) - to test if port is taken
* [miyako/workers](https://github.com/miyako/workers) - to manage `4D.SysytemWorker` instances
