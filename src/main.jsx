import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.jsx';
import Portal from './Portal.jsx';
import StaffConsole from './StaffConsole.jsx';
import AdminConsole from './AdminConsole.jsx';
import './styles.css';

const path=window.location.pathname;
const Page=path==='/portal'?Portal:path==='/staff'?StaffConsole:path==='/admin'?AdminConsole:App;
createRoot(document.getElementById('root')).render(<React.StrictMode><Page /></React.StrictMode>);
