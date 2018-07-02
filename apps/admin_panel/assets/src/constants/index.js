export default {
  AUTHENTICATION_TOKEN: 'ACCESS_TOKEN',
  CURRENT_ACCOUNT_ID: 'CURRENT_ACCOUNT_ID',
  LOADING_STATUS: {
    SUCCESS: 'SUCCESS',
    FAILED: 'FAILED',
    INITIATED: 'INITIATED',
    PENDING: 'PENDING',
    DEFAULT: 'DEFAULT'
  },
  WEBSOCKET: {
    JOIN_CHANNEL_REF: 'JOIN_CHANNEL',
    JOIN_CHANNEL_EVENT: 'phx_join',
    LEAVE_CHANNEL_REF: 'LEAVE_CHANNEL',
    LEAVE_CHANNEL_EVENT: 'phx_leave',
    HEARTBEAT_EVENT: 'heartbeat',
    HEARTBEAT_TOPIC: 'phoenix'
  }
}
