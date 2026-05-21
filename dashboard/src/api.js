/**
 * api.js - Servicio para conectar con PostgREST
 * 
 * Este archivo centraliza todas las llamadas a la base de datos a través de 
 * la API REST proporcionada por PostgREST.
 */

const API_BASE_URL = '/api'; // El proxy de Vite se encargará de enviarlo a localhost:3000

/**
 * Realiza una petición GET a una tabla de PostgREST.
 * @param {string} endpoint - El nombre de la tabla o vista (ej. 'orders', 'menu_items')
 * @param {string} query - Query params adicionales (ej. '?select=id,name&order=id.desc')
 * @returns {Promise<Array>} - Los resultados en formato JSON
 */
export async function fetchTable(endpoint, query = '') {
  try {
    const response = await fetch(`${API_BASE_URL}/${endpoint}${query}`);
    
    if (!response.ok) {
      throw new Error(`Error HTTP: ${response.status} - ${response.statusText}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error(`Error fetching ${endpoint}:`, error);
    return []; // Retorna un array vacío en caso de error para evitar que la UI se rompa
  }
}

/**
 * Helper para construir query string a partir de establishmentId y date
 */
function buildQuery(establishmentId, date, dateColumn = 'date') {
  const params = new URLSearchParams();
  
  if (establishmentId && establishmentId !== 'all') {
    params.append('establishment_id', `eq.${establishmentId}`);
  }
  
  if (date) {
    let dateStr = date;
    if (date === 'realtime') {
      dateStr = new Date().toISOString().split('T')[0];
    }
    
    // Si la columna es un timestamp (ej. created_at), debemos buscar entre inicio y fin del día
    if (dateColumn === 'created_at') {
      params.append(dateColumn, `gte.${dateStr}T00:00:00`);
      params.append(dateColumn, `lte.${dateStr}T23:59:59`);
    } else {
      params.append(dateColumn, `eq.${dateStr}`);
    }
  }
  
  const queryString = params.toString();
  return queryString ? `?${queryString}` : '';
}

// Establecimientos
export async function getEstablishments() {
  return await fetchTable('establishments', '?is_active=eq.true');
}

export async function getOrders(establishmentId, date) {
  return await fetchTable('orders', buildQuery(establishmentId, date, 'created_at'));
}

export async function getMenuItems() {
  return await fetchTable('menu_card_items');
}

export async function getTablesList() {
  return await fetchTable('tables');
}

export async function getAllergenAlerts(establishmentId, date) {
  return await fetchTable('allergen_alerts', buildQuery(establishmentId, date, 'created_at'));
}

export async function getStaff() {
  return await fetchTable('users');
}

// Ventas (SalesPage)
export async function getSalesWeeklyRevenue(establishmentId, date) {
  const params = new URLSearchParams();
  if (establishmentId && establishmentId !== 'all') {
    params.append('establishment_id', `eq.${establishmentId}`);
  }
  
  let targetDate = new Date();
  if (date && date !== 'realtime') {
    targetDate = new Date(date);
  }
  
  const pastDate = new Date(targetDate);
  pastDate.setDate(pastDate.getDate() - 6);
  
  const targetDateStr = targetDate.toISOString().split('T')[0];
  const pastDateStr = pastDate.toISOString().split('T')[0];
  
  params.append('order_date', `gte.${pastDateStr}`);
  params.append('order_date', `lte.${targetDateStr}`);
  
  const queryString = params.toString();
  return await fetchTable('view_sales_weekly_revenue', queryString ? `?${queryString}` : '');
}

export async function getSalesByEstablishment(establishmentId, date) {
  return await fetchTable('view_sales_by_establishment', buildQuery(establishmentId, date));
}

export async function getSalesByCategory(establishmentId, date) {
  return await fetchTable('view_sales_by_category', buildQuery(establishmentId, date));
}

export async function getSalesTopDishes(establishmentId, date) {
  return await fetchTable('view_sales_top_dishes', buildQuery(establishmentId, date));
}

// Pedidos (OrdersPage)
export async function getOrdersHourly(establishmentId, date) {
  return await fetchTable('view_orders_hourly', buildQuery(establishmentId, date));
}

export async function getOrdersRoomPerformance(establishmentId, date) {
  return await fetchTable('view_orders_room_performance', buildQuery(establishmentId, date));
}

export async function getOrderStageTimes(establishmentId, date) {
  return await fetchTable('view_orders_stage_times', buildQuery(establishmentId, date));
}

// Mesas (TablesPage)
export async function getTablesStatus(establishmentId, date) {
  return await fetchTable('view_tables_status', buildQuery(establishmentId, date));
}

export async function getTablesSizeDistribution(establishmentId, date) {
  return await fetchTable('view_tables_size_distribution', buildQuery(establishmentId, date));
}

// Personal (StaffPage)
export async function getStaffPerformance(establishmentId, date) {
  return await fetchTable('view_staff_performance', buildQuery(establishmentId, date));
}

export async function getStaffZones(establishmentId, date) {
  return await fetchTable('view_staff_zones', buildQuery(establishmentId, date));
}

export async function getStaffActivityLog(establishmentId, date) {
  return await fetchTable('view_staff_activity_log', buildQuery(establishmentId, date));
}

// Alérgenos (AllergensPage)
export async function getAllergensFrequency(establishmentId, date) {
  return await fetchTable('view_allergens_frequency', buildQuery(establishmentId, date));
}

export async function getAllergensHeatmap(establishmentId, date) {
  return await fetchTable('view_allergens_heatmap', buildQuery(establishmentId, date));
}

export async function getAllergensPresence(establishmentId, date) {
  return await fetchTable('view_allergens_presence', buildQuery(establishmentId, date));
}

export async function getAllergensAlertsRecent(establishmentId, date) {
  return await fetchTable('view_allergens_alerts_recent', buildQuery(establishmentId, date));
}

export async function getAllergensAlternatives(establishmentId, date) {
  return await fetchTable('view_allergens_alternatives', buildQuery(establishmentId, date));
}

export async function getTicketDistribution(establishmentId, date) {
  return await fetchTable('view_sales_ticket_distribution', buildQuery(establishmentId, date));
}

export async function getOrdersPipeline(establishmentId, date) {
  return await fetchTable('view_orders_pipeline', buildQuery(establishmentId, date));
}

export async function getOrdersFeed(establishmentId, date) {
  return await fetchTable('view_orders_feed', buildQuery(establishmentId, date));
}

export async function getTopCancellations(establishmentId, date) {
  return await fetchTable('view_orders_top_cancellations', buildQuery(establishmentId, date));
}
