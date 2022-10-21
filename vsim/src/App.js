import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [stateDoors, setStateDoor] = useState(0);
  const [airTemperature, setAirTemperature] = useState(0);
  const FRONT_LEFT_DOOR  = 0b00001;
  const FRONT_RIGHT_DOOR = 0b00010;
  const REAR_LEFT_DOOR   = 0b00100;
  const REAR_RIGHT_DOOR  = 0b01000;
  const TRUNK_DOOR       = 0b10000;

  useEffect(() => {
    fetch('/api/signal/HS1_ETAT_OUVRANTS', {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    }).then(res => res.json()).then(data => {
      setStateDoor(data.value);
    });
    fetch('/api/signal/HS1_TEMP_AIR_EXT', {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    }).then(res => res.json()).then(data => {
      setAirTemperature(data.value);
    });
  }, []);

  const toggleDoor = (door) => {
    fetch('/api/signal/HS1_ETAT_OUVRANTS', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        value: (stateDoors & door) ? stateDoors & ~door : stateDoors | door})
    }).then(res => res.json()).then(data => {
      setStateDoor(data.value);
    });    
  };

  const setTemperature = (value) => {
    fetch('/api/signal/HS1_TEMP_AIR_EXT', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        value
      })
    }).then(res => res.json()).then(data => {
      setAirTemperature(data.value);
    });        
  }

  const getStateDoor = (door) => {
    return (stateDoors & door) ? 'Opened' :'Closed'
  }

  return (
    <div className="App">
      <header className="App-header">
        <div>
          Left Front Door <button type="button" onClick={() => toggleDoor(FRONT_LEFT_DOOR)}>{getStateDoor(FRONT_LEFT_DOOR)}</button>
        </div>
        <div>
          Right Front Door <button type="button" onClick={() => toggleDoor(FRONT_RIGHT_DOOR)}>{getStateDoor(FRONT_RIGHT_DOOR)}</button>
        </div>
        <div>
          Left Rear Door <button type="button" onClick={() => toggleDoor(REAR_LEFT_DOOR)}>{getStateDoor(REAR_LEFT_DOOR)}</button>
        </div>
        <div>
          Right Rear Door <button type="button" onClick={() => toggleDoor(REAR_RIGHT_DOOR)}>{getStateDoor(REAR_RIGHT_DOOR)}</button>
        </div>
        <div>
          Trunk <button type="button" onClick={() => toggleDoor(TRUNK_DOOR)}>{getStateDoor(TRUNK_DOOR)}</button>
        </div>
        <div>
          <button type="button" onClick={() => setTemperature(airTemperature-0.5)}>-</button>
          {airTemperature}
          <button type="button" onClick={() => setTemperature(airTemperature+0.5)}>+</button>
        </div>
      </header>
    </div>
  );
}

export default App;