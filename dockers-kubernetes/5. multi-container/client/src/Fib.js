import React, { Component, useEffect, useState } from 'react';
import axios from 'axios';

function Fib() {
  const [seenIndexes, setSeenIndexes] = useState([]);
  const [values, setValues] = useState({});
  const [index, setIndex] = useState('');

  const fetchValues = async () => {
    const response = await axios.get('/api/values/current');
    setValues(response.data);
  };

  const fetchIndexes = async () => {
    const response = await axios.get('/api/values/all');
    setSeenIndexes(response.data);
  };

  useEffect(() => {
    fetchValues();
    fetchIndexes();
  }, []);

  const handleSubmit = async (event) => {
    event.preventDefault();

    await axios.post('/api/values', {
      index: index,
    });
    setIndex('');
    
    // Actualizar después de enviar para ver el resultado
    setTimeout(() => {
      fetchValues();
      fetchIndexes();
    }, 500);
    
    // Actualizar nuevamente después de 2 segundos para ver el cálculo del worker
    setTimeout(() => {
      fetchValues();
      fetchIndexes();
    }, 2000);
  };

  const renderSeenIndexes = () => {
    return seenIndexes.map(({ number }) => number).join(', ');
  };

  const renderValues = () => {
    const entries = [];

    for (let key in values) {
      entries.push(
        <div key={key}>
          For index {key} I calculated {values[key]}
        </div>
      );
    }

    return entries;
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <label>Enter your index:</label>
        <input
          value={index}
          onChange={(event) => setIndex(event.target.value)}
        />
        <button>Submit</button>
      </form>

      <h3>Indexes I have seen:</h3>
      {renderSeenIndexes()}

      <h3>Calculated Values:</h3>
      {renderValues()}
    </div>
  );
}

export default Fib;
