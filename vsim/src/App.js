import React, { useState, useEffect } from 'react';
import { Button, FormLabel } from 'react-bootstrap';
import 'react-bootstrap-range-slider/dist/react-bootstrap-range-slider.css';
import RangeSlider from 'react-bootstrap-range-slider';
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
        value: parseFloat(value)
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

        <table>
            <tr>
              <td></td>
              <td>
                <RangeSlider
                  value={airTemperature}
                  min={-40.0}
                  max={85}
                  size={'lg'}
                  onChange={changeEvent => setTemperature(changeEvent.target.value)}
                />
                <FormLabel>External Air Temperature {airTemperature} °C</FormLabel>
              </td>
            </tr>
          <tr>
            <td>
              <tr>
                <Button variant="secondary" onClick={() => toggleDoor(FRONT_LEFT_DOOR)}>{getStateDoor(FRONT_LEFT_DOOR)}</Button>
              </tr>
              <tr><span>&nbsp;</span></tr>
              <tr><span>&nbsp;</span></tr>
              <tr>
                <Button variant="secondary" onClick={() => toggleDoor(REAR_LEFT_DOOR)}>{getStateDoor(REAR_LEFT_DOOR)}</Button>
              </tr>
            </td>
              <img src="car.png"/>
            <td>
              <tr>
                <Button variant="secondary" onClick={() => toggleDoor(FRONT_RIGHT_DOOR)}>{getStateDoor(FRONT_RIGHT_DOOR)}</Button>
              </tr>
              <tr><span>&nbsp;</span></tr>
              <tr><span>&nbsp;</span></tr>
              <tr>
                <Button variant="secondary" onClick={() => toggleDoor(REAR_RIGHT_DOOR)}>{getStateDoor(REAR_RIGHT_DOOR)}</Button>
              </tr>
            </td>
          </tr>
          <tr>
            <td>
            </td>
            <td>
              <center>
                <Button variant="secondary" onClick={() => toggleDoor(TRUNK_DOOR)}>{getStateDoor(TRUNK_DOOR)}</Button>
              </center>
            </td>
          </tr>
        </table>
      </header>
    </div>
  );
}

export default App;