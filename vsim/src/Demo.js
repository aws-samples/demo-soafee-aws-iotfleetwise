import { Box, Button } from '@cloudscape-design/components';
import "@cloudscape-design/global-styles/index.css";
import React, { useEffect, useState } from 'react';
import { FormLabel } from 'react-bootstrap';
import RangeSlider from 'react-bootstrap-range-slider';
import 'react-bootstrap-range-slider/dist/react-bootstrap-range-slider.css';
import './App.css';


const Demo = () => {
  const [stateDoors, setStateDoor] = useState(0);
  const [airTemperature, setAirTemperature] = useState(0);
  const FRONT_LEFT_DOOR = 0b00001;
  const FRONT_RIGHT_DOOR = 0b00010;
  const REAR_LEFT_DOOR = 0b00100;
  const REAR_RIGHT_DOOR = 0b01000;
  const TRUNK_DOOR = 0b10000;

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
        value: (stateDoors & door) ? stateDoors & ~door : stateDoors | door
      })
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
    return (stateDoors & door) ? 'Opened' : 'Closed'
  }

  return (
    <Box className="demo-content">
      <div className='top'>
        <FormLabel>External Air Temperature {airTemperature} °C</FormLabel>
        <RangeSlider
          value={airTemperature}
          min={-40.0}
          max={85}
          size={'lg'}
          onChange={changeEvent => setTemperature(changeEvent.target.value)}
        />
      </div>
      <div className='car-container'>
        <div className='demo-left'>
          <div className='button-container'>
            <Button variant="primary" onClick={() => toggleDoor(FRONT_LEFT_DOOR)}>{getStateDoor(FRONT_LEFT_DOOR)}</Button>
            <p/><p/>
            <Button variant="primary" onClick={() => toggleDoor(REAR_LEFT_DOOR)}>{getStateDoor(REAR_LEFT_DOOR)}</Button>
          </div>
        </div>
        <div className='demo-center'>
          <img src="car_with_logo.png" className='car' alt='car' />
        </div>
        <div className='demo-right'>
          <div className='button-container'>
            <Button variant="primary" onClick={() => toggleDoor(FRONT_RIGHT_DOOR)}>{getStateDoor(FRONT_RIGHT_DOOR)}</Button>
            <p/><p/>
            <Button variant="primary" onClick={() => toggleDoor(REAR_RIGHT_DOOR)}>{getStateDoor(REAR_RIGHT_DOOR)}</Button>
          </div>
        </div>
      </div>
      <div className='bottom'>
        <Button variant="primary" onClick={() => toggleDoor(TRUNK_DOOR)}>{getStateDoor(TRUNK_DOOR)}</Button>
      </div>
    </Box>
  )
}

export default Demo;
