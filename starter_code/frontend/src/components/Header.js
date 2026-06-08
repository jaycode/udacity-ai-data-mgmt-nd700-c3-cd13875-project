import React from 'react';
import { Link } from 'react-router-dom';

function Header({ cartItemCount }) {
  return (
    <header className="header">
      <div className="header-content">
        <Link to="/" className="header-logo">
          ShopFast
        </Link>
        <nav className="header-nav">
          <Link to="/" className="header-link">
            Products
          </Link>
          <Link to="/cart" className="header-link">
            Cart
            {cartItemCount > 0 && (
              <span className="cart-badge">{cartItemCount}</span>
            )}
          </Link>
        </nav>
      </div>
    </header>
  );
}

export default Header;
