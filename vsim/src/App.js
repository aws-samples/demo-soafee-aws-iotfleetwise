import { Container, Tabs } from '@cloudscape-design/components';
import "@cloudscape-design/global-styles/index.css";
import React from 'react';
import 'react-bootstrap-range-slider/dist/react-bootstrap-range-slider.css';
import './App.css';
import Demo from './Demo';
import Gallery from './Gallery';
import TopNav from './TopNav';


function App() {

  return (
    <div className="App">
      <TopNav />
        <Container>
          <Tabs
            tabs={[
              {
                label: "Vehicle Simulator",
                id: "demo",
                content: <Demo/>
              },
              {
                label: "Architecture",
                id: "gallery",
                content: <Gallery />
              }
            ]}
          />
        </Container>
      {/*</FleetwiseAppLayout>*/}
    </div>
  );
}

export default App;