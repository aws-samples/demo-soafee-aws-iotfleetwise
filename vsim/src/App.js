import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [isLeftFrontDoor, setleftFrontDoor] = useState(false);

  useEffect(() => {
    fetch('/api/signal/Gear').then(res => res.json()).then(data => {
      setleftFrontDoor(data.value);
    });
  }, []);

  const handleClick = () => {
    fetch('/api/signal/Gear', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({value: (isLeftFrontDoor) ? 0 : 1})
    }).then(res => res.json()).then(data => {
      console.log(data)
      setleftFrontDoor(data.value);
    });    
  };

  return (
    <div className="App">
      <header className="App-header">
        <div>
          Left Front Door <button type="button" onClick={handleClick}>{(isLeftFrontDoor)? 'Open' :'Closed'}</button>
        </div>
        <div>
          Right Front Door <button type="button" onClick={handleClick}>{(isLeftFrontDoor)? 'Open' :'Closed'}</button>
        </div>
        <div>
          Left Rear Door <button type="button" onClick={handleClick}>{(isLeftFrontDoor)? 'Open' :'Closed'}</button>
        </div>
        <div>
          Right Rear Door <button type="button" onClick={handleClick}>{(isLeftFrontDoor)? 'Open' :'Closed'}</button>
        </div>
        <div>
          Trunk <button type="button" onClick={handleClick}>{(isLeftFrontDoor)? 'Open' :'Closed'}</button>
        </div>
      </header>
    </div>
  );
}

export default App;