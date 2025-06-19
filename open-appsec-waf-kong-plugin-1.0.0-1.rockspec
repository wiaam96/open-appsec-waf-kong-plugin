package = "open-appsec-waf-kong-plugin"
version = "1.0.0-1"

source = {
  url = "git+https://github.com/wiaam96/open-appsec-waf-kong-plugin.git",
  branch = "main"
}

description = {
  summary = "Kong plugin for scanning headers using Nano Attachment",
  detailed = [[
    A Kong plugin that scans HTTP request headers using C logic from Nano Attachment.
  ]],
  homepage = "https://github.com/wiaam96/open-appsec-waf-kong-plugin",
  license = "Apache"
}

dependencies = {
  "lua >= 5.1"
}

build = {
  type = "builtin",

  build_command = [[
    echo "Cloning attachment repo..." &&
    rm -rf tmp_attachment &&
    git clone --depth 1 https://github.com/openappsec/attachment tmp_attachment &&
    echo "Copying required directories..." &&
    mkdir -p attachments/attachment &&
    cp -r tmp_attachment/attachments/nano_attachment attachments/attachment/ &&
    cp -r tmp_attachment/core attachments/attachment/ &&
  ]],

  modules = {
    ["kong.plugins.open-appsec-waf-kong-plugin.handler"] = "handler.lua",
    ["kong.plugins.open-appsec-waf-kong-plugin.nano_ffi"] = "nano_ffi.lua",
    ["kong.plugins.open-appsec-waf-kong-plugin.schema"]   = "schema.lua",

    ["lua_attachment_wrapper"] = {
      sources = {
        "lua_attachment_wrapper.c",
        "attachments/attachment/nano_attachment/nano_attachment.c",
        "attachments/attachment/nano_attachment/nano_attachment_io.c",
        "attachments/attachment/nano_attachment/nano_attachment_metric.c",
        "attachments/attachment/nano_attachment/nano_attachment_sender.c",
        "attachments/attachment/nano_attachment/nano_attachment_sender_thread.c",
        "attachments/attachment/nano_attachment/nano_attachment_thread.c",
        "attachments/attachment/nano_attachment/nano_compression.c",
        "attachments/attachment/nano_attachment/nano_configuration.c",
        "attachments/attachment/nano_attachment/nano_initializer.c",
        "attachments/attachment/nano_attachment/nano_utils.c",
        "attachments/attachment/nano_attachment/nano_attachment_util/nano_attachment_util.cc",
        "attachments/attachment/core/attachments/http_configuration/http_configuration.cc",
        "attachments/attachment/core/compression/compression_utils.cc",
        "attachments/attachment/core/shmem_ipc_2/shared_ring_queue.c",
        "attachments/attachment/core/shmem_ipc_2/shmem_ipc.c"
      },
      incdirs = {
        "attachments/attachment/core/include/attachments/",
        "attachments/attachment/nano_attachment/",
        "attachments/attachment/core/include/attachments"
      },
      defines = { "_GNU_SOURCE", "ZLIB_CONST" },
      libraries = { "pthread", "z", "rt", "stdc++" },
      ldflags = { "-static-libstdc++", "-static-libgcc" }
    }
  }
}
