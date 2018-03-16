import React from 'react'
import PropTypes from "prop-types";

const Footer = ({author}) =>
    <footer id="footer">
        <div className="inner">
            <ul className="copyright">
                <li>&copy; {author}</li><li>Design: <a href="https://html5up.net">HTML5 UP</a></li>
            </ul>
        </div>
    </footer>

Footer.propTypes = {
    author: PropTypes.string
};

export default Footer