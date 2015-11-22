//The MIT License(MIT)

//Copyright(c) 2015 Phil Lira

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

using UnityEngine;

public class OverdrawDebugReplacement : MonoBehaviour
{
    public Shader _OverdrawShader;

    private Camera _Camera;
    private bool _SceneFogSettings = false;

    void OnLevelWasLoaded()
    {
        // Every time a scene is loaded we have to disable fog. We save it for restorting it later in OnDisable
        _SceneFogSettings = RenderSettings.fog;
        RenderSettings.fog = false;
    }

    void OnEnable()
    {
        // not set in the editor inspector
        if (_OverdrawShader == null)
        {
            // It must be added on Project Settings -> Graphics -> Always Include Shader if you want to see it on the build.
            _OverdrawShader = Shader.Find("Custom/OverdrawDebugReplacement");
        }

        _Camera = GetComponent<Camera>();

        if (_OverdrawShader != null && _Camera != null)
        {
            RenderSettings.fog = false;
            Camera camera = GetComponent<Camera>();
            camera.SetReplacementShader(_OverdrawShader, "");
        }
        else
        {
            Debug.LogWarning("Can't use OverdrawDebugReplace. Check if script is attached to a camera object.");
        }
    }

    void OnDisable()
    {
        if (_Camera != null)
        {
            RenderSettings.fog = _SceneFogSettings;
            _Camera.SetReplacementShader(null, "");
        }
    }
}
