﻿using System;
using System.Threading.Tasks;
using Microsoft.AspNet.Hosting.Server;
using Microsoft.AspNet.Http.Features;

namespace OmniSharp.Stdio.Tests
{
    public class MockHttpApplication : IHttpApplication<int>
    {
        public Func<int, Task> ProcessAction { get; set; } = context => Task.FromResult(0);

        public int CreateContext(IFeatureCollection contextFeatures) => 0;

        public void DisposeContext(int context, Exception exception) { }

        public Task ProcessRequestAsync(int context) => ProcessAction(context);
    }
}
