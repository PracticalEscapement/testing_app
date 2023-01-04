# DO NOT CHANGE SPEC FILES

# Tips

Feel free to use online resources to help you through the specs.

The specs build on eachother, so we recommend completing them in the following order:

1. models
2. requests

## Authentication

You'll want to use `has_secure_password` for adding authentication to your user class.

## Validations

Some of the specs might require custom validations to be implemented to pass.

# Hints

You'll need to create the JsonWebToken class to implement token based authentication, it should have an `encode` method that takes a payload and returns a JWT, and a `decode` method that takes a JWT and returns the original payload. The `jwt` gem is provided.

## Final Thoughts

Remember that this test is supposed to measure how well you can adapt and problem-solve. Please use Stack Overflow or any other online resource if you run into problems. It's okay if you don't make it through all of the specs, very few people do, and not finishing **will not disqualify you.**

**Good Luck!**
