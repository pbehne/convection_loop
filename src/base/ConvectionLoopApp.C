#include "ConvectionLoopApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
ConvectionLoopApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  return params;
}

ConvectionLoopApp::ConvectionLoopApp(InputParameters parameters) : MooseApp(parameters)
{
  ConvectionLoopApp::registerAll(_factory, _action_factory, _syntax);
}

ConvectionLoopApp::~ConvectionLoopApp() {}

void
ConvectionLoopApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAll(f, af, syntax);
  Registry::registerObjectsTo(f, {"ConvectionLoopApp"});
  Registry::registerActionsTo(af, {"ConvectionLoopApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
ConvectionLoopApp::registerApps()
{
  registerApp(ConvectionLoopApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
ConvectionLoopApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ConvectionLoopApp::registerAll(f, af, s);
}
extern "C" void
ConvectionLoopApp__registerApps()
{
  ConvectionLoopApp::registerApps();
}
