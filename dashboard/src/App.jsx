/*
 * App.jsx — Componente raíz del Dashboard de CalBlay
 *
 * ¿Qué hace este archivo?
 * Es el "director de orquesta" de toda la aplicación. Se encarga de:
 * 1. Mantener en memoria qué página está activa (ej. "overview", "sales"...)
 * 2. Mantener qué establecimiento está seleccionado (o "todos")
 * 3. Mostrar siempre el Sidebar (menú lateral) y el Header (barra superior)
 * 4. Renderizar la página correspondiente en el área de contenido central
 *
 * ¿Cómo funciona la navegación?
 * Usamos un "estado" de React (useState) que guarda el ID de la página activa.
 * Cuando haces clic en un enlace del Sidebar, este llama a "setActivePage"
 * que cambia el estado, y React automáticamente re-renderiza la página correcta.
 * (Más adelante se puede reemplazar por react-router para URLs reales)
 */

import { useState, useEffect } from 'react'
import Sidebar from './components/Sidebar'
import Header from './components/Header'
import OverviewPage from './pages/OverviewPage'
import AllergensPage from './pages/AllergensPage'
import SalesPage from './pages/SalesPage'
import OrdersPage from './pages/OrdersPage'
import TablesPage from './pages/TablesPage'
import StaffPage from './pages/StaffPage'
import { getEstablishments } from './api'
import './App.css'

function App() {
  /* Estado que guarda los establecimientos obtenidos de la BD */
  const [establishments, setEstablishments] = useState([
    { id: 'all', name: 'Todos los Restaurantes', icon: '🏢' }
  ])

  /* Cargar establecimientos al iniciar */
  useEffect(() => {
    async function loadEstablishments() {
      try {
        const data = await getEstablishments()
        if (data && data.length > 0) {
          const formatted = data.map(est => ({
            id: est.id,
            name: est.name,
            icon: est.name.toLowerCase().includes('port') ? '⛵' : (est.name.toLowerCase().includes('centro') ? '🏙️' : '🍴'),
            address: est.address
          }))
          setEstablishments([{ id: 'all', name: 'Todos los Restaurantes', icon: '🏢' }, ...formatted])
        }
      } catch (error) {
        console.error("Error cargando establecimientos", error)
      }
    }
    loadEstablishments()
  }, [])

  /* Estado que guarda qué página está activa.
     Por defecto arrancamos en 'overview' (Vista General) */
  const [activePage, setActivePage] = useState('overview')

  /* Estado que guarda qué establecimiento está seleccionado.
     'all' = todos los restaurantes (vista global).
     En el futuro, al cambiar este valor, todas las páginas filtrarán
     sus consultas SQL añadiendo: WHERE establishment_id = :id */
  const [selectedEstablishment, setSelectedEstablishment] = useState('all')

  /* Estado que guarda la fecha seleccionada para las estadísticas.
     'realtime' = En tiempo real (por defecto)
     ISO String (ej. '2026-05-15') = Fecha específica */
  const [selectedDate, setSelectedDate] = useState('realtime')

  /* Función para renderizar la página correspondiente según el ID */
  const renderPage = () => {
    switch (activePage) {
      case 'overview':
        return <OverviewPage establishmentId={selectedEstablishment} date={selectedDate} />
      case 'allergens':
        return <AllergensPage establishmentId={selectedEstablishment} date={selectedDate} />
      case 'sales':
        return <SalesPage establishmentId={selectedEstablishment} date={selectedDate} />
      case 'orders':
        return <OrdersPage establishmentId={selectedEstablishment} date={selectedDate} />
      case 'tables':
        return <TablesPage establishmentId={selectedEstablishment} date={selectedDate} />
      case 'staff':
        return <StaffPage establishmentId={selectedEstablishment} date={selectedDate} />
      /* Las demás páginas se irán añadiendo progresivamente */
      default:
        return (
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            height: '60vh',
            gap: '1rem',
            color: 'var(--text-secondary)',
          }}>
            <span style={{ fontSize: '3rem' }}>🚧</span>
            <h2 style={{ color: 'var(--text-primary)', fontWeight: 600 }}>
              Página en desarrollo
            </h2>
            <p>La sección "{activePage}" estará disponible próximamente.</p>
          </div>
        )
    }
  }

  return (
    <div className="app-layout">
      {/* Menú lateral fijo — siempre visible */}
      <Sidebar activePage={activePage} onNavigate={setActivePage} />

      {/* Barra superior fija — muestra título, selector de establecimiento y fecha */}
      <Header
        activePage={activePage}
        establishments={establishments}
        selectedEstablishment={selectedEstablishment}
        onEstablishmentChange={setSelectedEstablishment}
        selectedDate={selectedDate}
        onDateChange={setSelectedDate}
      />

      {/* Área de contenido principal — cambia según la página activa */}
      <main className="app-main">
        {renderPage()}
      </main>
    </div>
  )
}

export default App
