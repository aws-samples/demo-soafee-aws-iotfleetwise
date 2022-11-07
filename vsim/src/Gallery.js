import React from 'react';
import SimpleImageSlider from "react-simple-image-slider";

const images = [
  { url: "Slide1.jpeg" },
  { url: "Slide2.jpeg" },
  { url: "Slide3.jpeg" },
];

const Gallery = () => {
  return (
    <div className='gallery'>
      <SimpleImageSlider
        width={1200}
        height={600}
        images={images}
        showBullets={true}
        showNavs={true}
      />
    </div>
  );
};

export default Gallery;