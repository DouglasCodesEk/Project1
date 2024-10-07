import React, { useEffect, useState } from 'react';
import ProjectVisualizer from './components/ProjectVisualizer';
import { optimizePerformance } from './performance';

function App() {
  const [testimonials, setTestimonials] = useState([]);

  useEffect(() => {
    const visualizer = new ProjectVisualizer('3d-container');
    visualizer.addProject('Revolutionary Project', { x: 0, y: 0, z: 0 });
    optimizePerformance();

    fetchTestimonials();
  }, []);

  const fetchTestimonials = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/testimonials');
      const data = await response.json();
      setTestimonials(data);
    } catch (error) {
      console.error('Error fetching testimonials:', error);
    }
  };

  return (
    <div className="App">
      <h1>Revolutionary Portfolio</h1>
      <div id="3d-container" style={{ width: '100%', height: '400px' }}></div>
      <h2>Testimonials</h2>
      <ul>
        {testimonials.map((testimonial, index) => (
          <li key={index}>
            <p>{testimonial.content}</p>
            <small>By: {testimonial.author}</small>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
