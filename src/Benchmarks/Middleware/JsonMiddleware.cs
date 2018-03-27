// Copyright (c) .NET Foundation. All rights reserved.
// Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information.

using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Benchmarks.Configuration;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json;

namespace Benchmarks.Middleware
{
    public class JsonMiddleware
    {
        private static readonly PathString _path = new PathString(Scenarios.GetPath(s => s.Json));
        private static readonly JsonSerializer _json = new JsonSerializer();
        private static readonly UTF8Encoding _encoding = new UTF8Encoding(false);
        private const int _bufferSize = 27;

        private static readonly ReadOnlyMemory<byte> s_buffer = Encoding.UTF8.GetBytes("{\"message\":\"Hello, World!\"}");

        private readonly RequestDelegate _next;

        public JsonMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public Task Invoke(HttpContext httpContext)
        {
            if (httpContext.Request.Path.StartsWithSegments(_path, StringComparison.Ordinal))
            {
                httpContext.Response.StatusCode = 200;
                httpContext.Response.ContentType = "application/json";
                httpContext.Response.ContentLength = _bufferSize;

                httpContext.Response.Body.Write(s_buffer.Span);

                return Task.CompletedTask;
            }

            return _next(httpContext);
        }
    }

    public static class JsonMiddlewareExtensions
    {
        public static IApplicationBuilder UseJson(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<JsonMiddleware>();
        }
    }
}
