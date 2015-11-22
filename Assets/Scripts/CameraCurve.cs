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
using System.Collections;

public class CameraCurve : MonoBehaviour
{
    private GameObject[] _CurvedGameObjects;
    private Vector3[][] _MeshVertices;
    private const string CurvedGeometryTag = "CurvedGeometry";
    public float _WorldLenght;

    void Start()
    {
        _CurvedGameObjects = GameObject.FindGameObjectsWithTag(CurvedGeometryTag);
        
        // Creates a copy of all curved geometry vertices.
        _MeshVertices = new Vector3[_CurvedGameObjects.Length][];
        for (int i = 0; i < _CurvedGameObjects.Length; ++i)
        {
            Mesh mesh = _CurvedGameObjects[i].GetComponent<MeshFilter>().mesh;
            _MeshVertices[i] = new Vector3[mesh.vertexCount];
            for (int j = 0; j < mesh.vertexCount; ++j)
            {
                _MeshVertices[i][j] = mesh.vertices[j];
            }
        }
    }

    Vector3 RotateY(Vector3 v, float theta)
    {
        // rotation around up vector
        // | cos(theta), 0, -sin(theta) | ( x )
        // |     0     , 0,       0     | ( y )
        // | sin(theta), 0,  cos(theta) | ( z )
        float cosT = Mathf.Cos(theta);
        float sinT = Mathf.Sin(theta);
        return new Vector3(v.x * cosT - v.z * sinT, v.y, v.x * sinT + v.z * cosT);
    }

    Vector3 ApplyCurve(Vector3 vertex)
    {
        Vector3 camPos = transform.position;
        float radius = vertex.z - camPos.z;
        float s = vertex.x - camPos.x;

        // Right hand system rotates yaw right as negative angle
        float theta = s / radius;

        return Quaternion.AngleAxis(theta * Mathf.Rad2Deg, Vector3.up) * vertex;
    }

    void OnPreCull()
    {
        for (int i = 0; i < _CurvedGameObjects.Length; ++i)
        {
            GameObject go = _CurvedGameObjects[i];
            MeshFilter meshFilter = go.GetComponent<MeshFilter>();
            if (meshFilter != null)
            {
                Mesh mesh = meshFilter.mesh;
                Vector3[] vertices = mesh.vertices;

                for (int j = 0; j < vertices.Length; ++j)
                {
                    // TODO: Instead of transforming each vertice to world space, perform bending computation on local space.
                    vertices[j] = _CurvedGameObjects[i].transform.TransformPoint(_MeshVertices[i][j]);
                    vertices[j] = ApplyCurve(vertices[j]);
                    vertices[j] = _CurvedGameObjects[i].transform.InverseTransformPoint(vertices[j]);
                }
                mesh.vertices = vertices;
            }
        }
    }

    void DebugLine(Vector3 start, Vector3 end)
    {
#if DEBUG_RAYCAST
        Debug.DrawLine(start, end, Color.red);
#endif
    }
}
