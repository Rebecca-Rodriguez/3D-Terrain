class Camera
{
  int radius;
  float phi, theta;
  PVector cameraPosition;
  Camera()
  {
    radius = 50;
    phi = 2.2633219;
    theta = 109.74534;
//    cameraPosition = new PVector(100, -100, 100);
  }

  PVector Update(PVector cameraPosition)
  {
    
    cameraPosition.x = radius * cos(radians(phi)) * sin(radians(theta));
    cameraPosition.y = radius * cos(radians(theta));
    cameraPosition.z = radius * sin(radians(theta)) * sin(radians(phi));

    return cameraPosition;
  }

  void Zoom (float pos)
  {
    radius = constrain(radius, 10, 200);
    radius += pos;
  }
};
