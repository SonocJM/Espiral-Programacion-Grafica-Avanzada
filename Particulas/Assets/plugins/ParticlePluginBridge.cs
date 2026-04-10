using UnityEngine;
using System.Runtime.InteropServices;
using System;

public class ParticlePluginBridge : MonoBehaviour
{
    [StructLayout(LayoutKind.Sequential)]
    public struct NativeParticle
    {
        public float x, y, z;          // Posición
        public float vy;               // Velocidad Y
        public float life;             // Vida
        public float angle;            // Datos de espiral
        public float radius;
        public float rotationSpeed;
    }

    [DllImport("NativeParticles")]
    private static extern void InitParticles(int count);
    [DllImport("NativeParticles")]
    private static extern void UpdateParticles(float deltaTime, float speed);
    [DllImport("NativeParticles")]
    private static extern IntPtr GetParticles();

    public int particleCount = 500;
    public float simulationSpeed = 1.0f;
    public GameObject particlePrefab;

    private Transform[] particleTransforms;

    void Start()
    {
        InitParticles(particleCount);
        particleTransforms = new Transform[particleCount];
        for (int i = 0; i < particleCount; i++)
        {
            particleTransforms[i] = Instantiate(particlePrefab, transform).transform;
        }
    }

    void Update()
    {
        UpdateParticles(Time.deltaTime, simulationSpeed);

        IntPtr particlePtr = GetParticles();
        int size = Marshal.SizeOf(typeof(NativeParticle));

        for (int i = 0; i < particleCount; i++)
        {
            // Calculamos el offset exacto en memoria
            IntPtr currentParticlePtr = new IntPtr(particlePtr.ToInt64() + i * size);
            NativeParticle p = Marshal.PtrToStructure<NativeParticle>(currentParticlePtr);

            // Aplicamos la posición (puedes sumarle la posición del objeto padre si quieres)
            particleTransforms[i].localPosition = new Vector3(p.x, p.y, p.z);
        }
    }
}