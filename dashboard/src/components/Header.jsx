/*
 * Header.jsx — Barra superior del Dashboard
 *
 * ¿Qué hace este componente?
 * Muestra la barra de la parte de arriba de la app con:
 * - El título de la página actual (cambia según en qué sección estés)
 * - Un SELECTOR DE ESTABLECIMIENTO para filtrar por restaurante
 * - Un indicador "EN VIVO" con un punto verde pulsante
 * - La fecha y hora en tiempo real (se actualiza cada segundo)
 * - Un botón de notificaciones con un conteo
 *
 * ¿Cómo funciona el selector de establecimiento?
 * Recibe la lista de establecimientos y el ID del seleccionado desde App.jsx.
 * Al hacer clic, se abre un desplegable (dropdown). Al elegir un restaurante,
 * llama a "onEstablishmentChange" que actualiza el estado en App.jsx.
 * En el futuro, este cambio hará que todas las páginas filtren sus datos
 * por ese establecimiento (añadiendo WHERE establishment_id = :id a las consultas).
 *
 * ¿Cómo funciona el reloj?
 * Usa "useState" para guardar la hora y "useEffect" con setInterval para
 * actualizarla cada segundo. Se limpia al desmontar el componente.
 */

import { useState, useEffect, useRef } from 'react'
import './Header.css'

/* Mapa que traduce el ID de la página a un título legible */
const pageTitles = {
  overview:   'Vista General',
  sales:      'Ventas',
  orders:     'Pedidos',
  kitchen:    'Cocina',
  tables:     'Ocupación',
  staff:      'Personal',
  allergens:  'Alérgenos',
  menu:       'Carta / Menú',
  events:     'Eventos',
  suppliers:  'Proveedores',
}

function Header({ activePage, establishments, selectedEstablishment, onEstablishmentChange, selectedDate, onDateChange }) {
  /* Estado para guardar la fecha/hora actual */
  const [now, setNow] = useState(new Date())

  /* Estado para controlar si el desplegable de establecimientos está abierto */
  const [dropdownOpen, setDropdownOpen] = useState(false)

  /* Referencia al elemento del dropdown para detectar clics fuera */
  const dropdownRef = useRef(null)
  const dateDropdownRef = useRef(null)

  /* Estado para controlar si el desplegable de fecha está abierto */
  const [dateDropdownOpen, setDateDropdownOpen] = useState(false)

  /* Efecto que crea un temporizador para actualizar la hora cada segundo */
  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000)
    return () => clearInterval(timer)
  }, [])

  /* Efecto para cerrar el dropdown al hacer clic fuera de él.
     ¿Cómo funciona? Escucha todos los clics en la página (document).
     Si el clic fue FUERA del dropdown, lo cierra. */
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setDropdownOpen(false)
      }
      if (dateDropdownRef.current && !dateDropdownRef.current.contains(event.target)) {
        setDateDropdownOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  /* Formateamos la fecha y hora al estilo español */
  const dateStr = now.toLocaleDateString('es-ES', {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
  const timeStr = now.toLocaleTimeString('es-ES', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  })

  /* Buscamos el objeto del establecimiento seleccionado para mostrar su nombre/icono */
  const currentEstablishment = establishments?.find(e => e.id === selectedEstablishment)
    || { name: 'Todos los Restaurantes', icon: '🏢' }

  /* Función para renderizar el valor seleccionado de fecha */
  const getDateDisplayValue = () => {
    if (selectedDate === 'realtime') return 'En tiempo real'
    // Formatear la fecha seleccionada (ej. '2026-05-15' -> '15 May 2026')
    const dateObj = new Date(selectedDate)
    return dateObj.toLocaleDateString('es-ES', { day: 'numeric', month: 'short', year: 'numeric' })
  }

  return (
    <header className="header">
      {/* ── Lado izquierdo: Título de la página + Selector de establecimiento ── */}
      <div className="header-left">
        <h1 className="header-title">
          {pageTitles[activePage] || 'Dashboard'}
        </h1>

        {/* ── Selector de Establecimiento (Dropdown) ── */}
        {establishments && (
          <div className="establishment-selector" ref={dropdownRef}>
            <button
              className={`establishment-selector-btn ${dropdownOpen ? 'open' : ''}`}
              onClick={() => setDropdownOpen(!dropdownOpen)}
              id="establishment-selector"
            >
              <span className="establishment-selector-icon">{currentEstablishment.icon}</span>
              <span className="establishment-selector-name">{currentEstablishment.name}</span>
              <span className={`establishment-selector-arrow ${dropdownOpen ? 'rotated' : ''}`}>▾</span>
            </button>

            {/* Menú desplegable — solo visible cuando dropdownOpen es true */}
            {dropdownOpen && (
              <div className="establishment-dropdown">
                {establishments.map((est) => (
                  <button
                    key={est.id}
                    className={`establishment-dropdown-item ${selectedEstablishment === est.id ? 'active' : ''}`}
                    onClick={() => {
                      onEstablishmentChange(est.id)
                      setDropdownOpen(false)
                    }}
                  >
                    <span className="establishment-dropdown-icon">{est.icon}</span>
                    <div className="establishment-dropdown-info">
                      <span className="establishment-dropdown-name">{est.name}</span>
                      {est.address && (
                        <span className="establishment-dropdown-address">{est.address}</span>
                      )}
                    </div>
                    {selectedEstablishment === est.id && (
                      <span className="establishment-dropdown-check">✓</span>
                    )}
                  </button>
                ))}
              </div>
            )}
          </div>
        )}

        {/* ── Selector de Fecha (Dropdown) ── */}
        <div className="establishment-selector" ref={dateDropdownRef}>
          <button
            className={`establishment-selector-btn ${dateDropdownOpen ? 'open' : ''}`}
            onClick={() => setDateDropdownOpen(!dateDropdownOpen)}
            id="date-selector"
          >
            <span className="establishment-selector-icon">
              {selectedDate === 'realtime' ? '🟢' : '📅'}
            </span>
            <span className="establishment-selector-name">{getDateDisplayValue()}</span>
            <span className={`establishment-selector-arrow ${dateDropdownOpen ? 'rotated' : ''}`}>▾</span>
          </button>

          {/* Menú desplegable para fecha */}
          {dateDropdownOpen && (
            <div className="establishment-dropdown date-dropdown">
              <button
                className={`establishment-dropdown-item ${selectedDate === 'realtime' ? 'active' : ''}`}
                onClick={() => {
                  onDateChange('realtime')
                  setDateDropdownOpen(false)
                }}
              >
                <span className="establishment-dropdown-icon">🟢</span>
                <div className="establishment-dropdown-info">
                  <span className="establishment-dropdown-name">En tiempo real</span>
                  <span className="establishment-dropdown-address">Datos actualizados al segundo</span>
                </div>
                {selectedDate === 'realtime' && <span className="establishment-dropdown-check">✓</span>}
              </button>

              <div className="date-picker-container">
                <label className="date-picker-label">Seleccionar fecha específica:</label>
                <input 
                  type="date" 
                  className="native-date-picker"
                  value={selectedDate === 'realtime' ? '' : selectedDate}
                  onChange={(e) => {
                    if (e.target.value) {
                      onDateChange(e.target.value)
                      setDateDropdownOpen(false)
                    }
                  }}
                  max={new Date().toISOString().split('T')[0]} // No permitir fechas futuras por defecto
                />
              </div>
            </div>
          )}
        </div>
      </div>

      {/* ── Lado derecho: Indicador en vivo, reloj, notificaciones ── */}
      <div className="header-right">
        {selectedDate === 'realtime' ? (
          <div className="header-live-badge">
            <span className="header-live-dot"></span>
            En vivo
          </div>
        ) : (
          <div className="header-live-badge historical">
            <span className="header-historical-icon">🗓️</span>
            Datos Históricos
          </div>
        )}

        <span className="header-datetime">
          {dateStr} · {timeStr}
        </span>

        <button className="header-notification-btn" id="notification-button">
          🔔
          <span className="header-notification-count">5</span>
        </button>
      </div>
    </header>
  )
}

export default Header
